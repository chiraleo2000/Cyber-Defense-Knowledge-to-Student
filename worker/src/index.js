/**
 * เช็คก่อนโอน — Agent Proxy (Cloudflare Worker)
 *
 * ทำไมต้องมี worker นี้: เว็บไซต์และเว็บแอปฝั่งเรา (GitHub Pages) เป็น static site ล้วนๆ
 * ไม่มี backend ของตัวเอง หากใส่ API key ของโมเดล LLM ไว้ในโค้ดฝั่ง client โดยตรง
 * ใครก็เปิดดู source code แล้วนำ key ไปใช้ได้ทันที และถ้า commit ขึ้น GitHub repo สาธารณะ
 * key จะรั่วถาวรอยู่ใน git history — worker นี้จึงทำหน้าที่เป็น "ตัวกลาง" เก็บ key ไว้ฝั่งเซิร์ฟเวอร์
 * (เป็น Cloudflare Secret ที่มองไม่เห็นจาก client) แล้วส่งต่อคำขอแทน
 *
 * หลังบ้านใช้ Pathumma (ThaiLLM ของ NECTEC): worker นี้เรียกโมเดล Pathumma ผ่าน endpoint แบบ
 * "OpenAI-compatible Chat Completions" ซึ่งเป็นมาตรฐานที่ผู้ให้บริการโฮสต์ Pathumma รองรับ เช่น
 *   - Featherless.ai        UPSTREAM_BASE_URL = https://api.featherless.ai/v1
 *                           MODEL_NAME        = nectec/Pathumma-llm-text-1.0.0
 *   - self-host เอง (vLLM/Ollama)  UPSTREAM_BASE_URL = https://your-server.example.com/v1
 *                           MODEL_NAME        = ชื่อโมเดล Pathumma ที่โหลดไว้บนเซิร์ฟเวอร์
 * ตั้งค่า UPSTREAM_BASE_URL + MODEL_NAME (ใน wrangler.toml) และ UPSTREAM_API_KEY (secret) ให้ตรงกับ
 * ผู้ให้บริการที่เลือก โดยไม่ต้องแก้โค้ดนี้
 *
 * Pathumma รุ่นใหม่ (เช่น 4.0.0) เป็น reasoning model ที่ใส่ "ร่องรอยการคิด" ไว้ใน <think>...</think>
 * ก่อนคำตอบจริง — worker นี้จะตัดส่วน <think> ออกให้อัตโนมัติ เพื่อส่งเฉพาะคำตอบสุดท้ายกลับไปให้ผู้ใช้
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

// ตัด "ร่องรอยการคิด" ที่โมเดล reasoning (เช่น Pathumma 4.0) ใส่มาใน <think>...</think>
// ออกให้เหลือเฉพาะคำตอบสุดท้าย — รองรับกรณีที่มีแท็กเปิดแต่ไม่มีแท็กปิดด้วย
function stripThinking(text) {
  if (!text) return "";
  let out = text.replace(/<think>[\s\S]*?<\/think>/gi, "");
  // เผื่อกรณีถูกตัด token ก่อนปิดแท็ก: ถ้ายังเหลือ <think> ค้าง ให้ตัดตั้งแต่ตรงนั้นทิ้ง
  const openIdx = out.search(/<think>/i);
  if (openIdx !== -1) out = out.slice(0, openIdx);
  return out.trim();
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
      model: env.MODEL_NAME || "nectec/Pathumma-llm-text-1.0.0",
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

    let reply =
      (data.choices && data.choices[0] && data.choices[0].message && data.choices[0].message.content) ||
      data.reply ||
      "";

    reply = stripThinking(reply);

    if (!reply) {
      return jsonResponse({ error: "empty_reply" }, 502, env);
    }

    return jsonResponse({ reply }, 200, env);
  },
};
