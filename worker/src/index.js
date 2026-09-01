/**
 * เช็คก่อนโอน — Agent Proxy (Cloudflare Worker)
 *
 * ทำไมต้องมี worker นี้: เว็บไซต์และเว็บแอปฝั่งเรา (GitHub Pages) เป็น static site ล้วนๆ
 * ไม่มี backend ของตัวเอง หากใส่ API key ของโมเดล LLM ไว้ในโค้ดฝั่ง client โดยตรง
 * ใครก็เปิดดู source code แล้วนำ key ไปใช้ได้ทันที และถ้า commit ขึ้น GitHub repo สาธารณะ
 * key จะรั่วถาวรอยู่ใน git history — worker นี้จึงทำหน้าที่เป็น "ตัวกลาง" เก็บ key ไว้ฝั่งเซิร์ฟเวอร์
 * (เป็น Cloudflare Secret ที่มองไม่เห็นจาก client) แล้วส่งต่อคำขอแทน
 *
 * หมายเหตุสำคัญเรื่อง Pathumma: จากการตรวจสอบ ณ ตอนที่เขียน worker นี้ Pathumma (ของ NECTEC)
 * เป็นชุดโมเดลโอเพนซอร์สที่เผยแพร่ให้ "self-host" เอง (ผ่าน llama.cpp / vLLM / Ollama) ไม่ได้มี
 * API สาธารณะแบบ ChatGPT ที่เรียกผ่านอินเทอร์เน็ตได้ทันที ดังนั้น worker นี้จึงถูกออกแบบให้ยืดหยุ่น:
 * รองรับ endpoint แบบ "OpenAI-compatible Chat Completions" (มาตรฐานที่ vLLM, Ollama, text-generation-webui,
 * llama.cpp server ฯลฯ ใช้ตรงกัน) — ไม่ว่า key ที่มีจะใช้กับบริการใดในที่สุด แค่ตั้งค่า UPSTREAM_BASE_URL
 * และ UPSTREAM_API_KEY (secret) ให้ตรงกับบริการนั้น worker นี้ก็ใช้งานได้ทันทีโดยไม่ต้องแก้โค้ด
 *
 * Endpoint ที่ worker นี้เปิดให้ใช้:
 *   POST /chat   body: { "messages": [{role:"user"|"assistant", content:"..."}, ...] }
 *   ตอบกลับ:      { "reply": "..." }  หรือ  { "error": "..." } เมื่อผิดพลาด/ยังไม่ได้ตั้งค่า
 */

const MAX_MESSAGES = 20;
const MAX_TOTAL_CHARS = 6000;
const MAX_REPLY_TOKENS = 500;

function corsHeaders(env) {
  const allowOrigin = env.ALLOWED_ORIGIN || "*";
  return {
    "Access-Control-Allow-Origin": allowOrigin,
    "Access-Control-Allow-Methods": "POST, OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type",
  };
}

function jsonResponse(body, status, env) {
  return new Response(JSON.stringify(body), {
    status: status || 200,
    headers: { "Content-Type": "application/json; charset=utf-8", ...corsHeaders(env) },
  });
}

export default {
  async fetch(request, env) {
    if (request.method === "OPTIONS") {
      return new Response(null, { headers: corsHeaders(env) });
    }

    const url = new URL(request.url);
    if (url.pathname !== "/chat" || request.method !== "POST") {
      return jsonResponse({ error: "not_found" }, 404, env);
    }

    if (!env.UPSTREAM_BASE_URL || !env.UPSTREAM_API_KEY) {
      // ยังไม่ได้ตั้งค่า secret — ตอบกลับข้อความชัดเจนแทนการ error แบบไม่รู้สาเหตุ
      return jsonResponse(
        {
          error: "not_configured",
          message:
            "worker ยังไม่ได้ตั้งค่า UPSTREAM_BASE_URL / UPSTREAM_API_KEY กรุณาดู worker/README.md",
        },
        503,
        env
      );
    }

    let payload;
    try {
      payload = await request.json();
    } catch (e) {
      return jsonResponse({ error: "invalid_json" }, 400, env);
    }

    const messages = Array.isArray(payload.messages) ? payload.messages : null;
    if (!messages || messages.length === 0) {
      return jsonResponse({ error: "missing_messages" }, 400, env);
    }
    if (messages.length > MAX_MESSAGES) {
      return jsonResponse({ error: "too_many_messages" }, 400, env);
    }
    const totalChars = messages.reduce((sum, m) => sum + (m && m.content ? String(m.content).length : 0), 0);
    if (totalChars > MAX_TOTAL_CHARS) {
      return jsonResponse({ error: "message_too_long" }, 400, env);
    }
    // sanitize roles — only allow user/assistant/system, everything else dropped
    const safeMessages = messages
      .filter((m) => m && typeof m.content === "string" && ["user", "assistant", "system"].includes(m.role))
      .map((m) => ({ role: m.role, content: m.content.slice(0, MAX_TOTAL_CHARS) }));

    const systemPrompt = {
      role: "system",
      content:
        env.SYSTEM_PROMPT ||
        "คุณเป็นผู้ช่วยให้คำแนะนำด้านความปลอดภัยไซเบอร์ภาษาไทย เชี่ยวชาญเรื่องภัยหลอกลวงแก๊งคอลเซ็นเตอร์ " +
          "Romance Scam และการหลอกลงทุน ตอบสั้น กระชับ ชัดเจน ปลอดภัยไว้ก่อน หากผู้ใช้บรรยายสถานการณ์ที่เข้าข่าย " +
          "ถูกหลอกอยู่ ณ ขณะนี้ ให้แนะนำวางสายทันทีและติดต่อสายด่วน AOC 1441 หรือ 191 เป็นอันดับแรกเสมอ",
    };

    const upstreamBody = {
      model: env.MODEL_NAME || "default",
      messages: [systemPrompt, ...safeMessages],
      max_tokens: MAX_REPLY_TOKENS,
      temperature: 0.4,
    };

    let upstreamRes;
    try {
      upstreamRes = await fetch(env.UPSTREAM_BASE_URL.replace(/\/$/, "") + "/chat/completions", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: "Bearer " + env.UPSTREAM_API_KEY,
        },
        body: JSON.stringify(upstreamBody),
        signal: AbortSignal.timeout(20000),
      });
    } catch (e) {
      return jsonResponse({ error: "upstream_unreachable", message: String(e && e.message) }, 502, env);
    }

    if (!upstreamRes.ok) {
      let detail = "";
      try {
        detail = await upstreamRes.text();
      } catch (e) {}
      return jsonResponse(
        { error: "upstream_error", status: upstreamRes.status, detail: detail.slice(0, 500) },
        502,
        env
      );
    }

    let data;
    try {
      data = await upstreamRes.json();
    } catch (e) {
      return jsonResponse({ error: "upstream_bad_json" }, 502, env);
    }

    const reply =
      (data.choices && data.choices[0] && data.choices[0].message && data.choices[0].message.content) ||
      data.reply ||
      "";

    if (!reply) {
      return jsonResponse({ error: "empty_reply" }, 502, env);
    }

    return jsonResponse({ reply }, 200, env);
  },
};
