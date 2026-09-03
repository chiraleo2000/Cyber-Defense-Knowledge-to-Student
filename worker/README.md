# Agent Proxy — วิธี Deploy

Worker นี้ทำหน้าที่เป็น "ตัวกลาง" ระหว่างเว็บแอปกับบริการ LLM (Pathumma หรือบริการอื่นที่ใช้ API key
เดียวกัน) เพื่อไม่ให้ API key รั่วไหลออกไปฝั่ง client — **จำเป็นต้อง deploy ก่อน** ฟีเจอร์ "ผู้ช่วย AI"
ในเว็บแอปจึงจะใช้งานได้ (ถ้าไม่ deploy เว็บแอปจะยังใช้งานได้ปกติทุกส่วน ยกเว้นฟีเจอร์แชทกับผู้ช่วย AI
ซึ่งจะแสดงข้อความแจ้งว่ายังไม่พร้อมใช้งาน แทนที่จะ error)

## หลังบ้านใช้ Pathumma (ThaiLLM ของ NECTEC)

ผู้ช่วย AI ในเว็บแอปเรียกโมเดลภาษาไทย **Pathumma** ผ่าน worker นี้ Pathumma เป็นโมเดลโอเพนซอร์ส
(ดู [huggingface.co/nectec](https://huggingface.co/nectec)) ที่ใช้งานได้ 2 ทางหลัก โดยทั้งสองทางพูดภาษา
มาตรฐานเดียวกันคือ **OpenAI-compatible Chat Completions** worker นี้จึงเรียกได้โดยไม่ต้องแก้โค้ด:

### ทางที่ 1 (ง่ายสุด): ใช้ผู้ให้บริการที่โฮสต์ Pathumma ให้แล้ว

ตัวอย่าง [Featherless.ai](https://featherless.ai) ที่มีโมเดล Pathumma พร้อมใช้:

- `UPSTREAM_BASE_URL` = `https://api.featherless.ai/v1`
- `MODEL_NAME` = `nectec/Pathumma-llm-text-1.0.0` (หรือ `nectec/thai-research-gemma-3-27b-it`)
- `UPSTREAM_API_KEY` = API key จากบัญชีผู้ให้บริการนั้น

### ทางที่ 2: self-host โมเดล Pathumma เอง

รันบนเซิร์ฟเวอร์ที่มี GPU เพียงพอด้วย vLLM หรือ Ollama ในโหมด OpenAI-compatible API แล้วตั้ง
`UPSTREAM_BASE_URL` เป็น URL เซิร์ฟเวอร์ของคุณ (เช่น `https://your-server.example.com/v1`) และ
`MODEL_NAME` ตามชื่อโมเดลที่โหลดไว้

> **ทดสอบ key/endpoint ก่อน deploy เสมอ** ด้วย curl ยิงตรงไป `<UPSTREAM_BASE_URL>/chat/completions`
> เพื่อยืนยันว่าใช้งานได้จริง แล้วค่อยนำมาตั้งค่า worker

> **หมายเหตุ:** Pathumma รุ่นใหม่ (เช่น 4.0.0) เป็น reasoning model ที่ใส่ร่องรอยการคิดใน `<think>...</think>`
> worker นี้ตัดส่วนนั้นออกให้อัตโนมัติแล้ว จึงส่งเฉพาะคำตอบสุดท้ายกลับไปที่เว็บแอป

## ขั้นตอน Deploy

ต้องมีบัญชี Cloudflare (สมัครฟรีได้ที่ [cloudflare.com](https://www.cloudflare.com)) และ Node.js ติดตั้งแล้ว

```bash
cd worker
npm install -g wrangler        # เครื่องมือ deploy ของ Cloudflare Workers
wrangler login                  # เข้าสู่ระบบ Cloudflare ผ่านเบราว์เซอร์

# ตั้งค่าความลับ (จะถูกถามให้พิมพ์ค่า ไม่แสดงผลบนหน้าจอ และไม่ถูกบันทึกลงไฟล์ใดๆ ในเครื่อง/repo)
wrangler secret put UPSTREAM_API_KEY
# วาง API key ของคุณตรงนี้ แล้วกด Enter

wrangler secret put UPSTREAM_BASE_URL
# วาง URL ของ endpoint (ไม่ต้องมี /chat/completions ต่อท้าย เช่น https://your-server.com/v1)

wrangler deploy
```

เมื่อ deploy สำเร็จ wrangler จะแสดง URL ของ worker เช่น
`https://check-kon-oon-agent-proxy.<your-subdomain>.workers.dev`

## หลัง Deploy: เชื่อมกับเว็บแอป

เลือกวิธีใดวิธีหนึ่งเพื่อชี้เว็บแอปไปที่ worker (URL ต้องลงท้ายด้วย `/chat`):

- **ง่ายสุด ไม่ต้องแก้โค้ด:** เปิดเว็บแอปด้วยพารามิเตอร์ครั้งเดียว เบราว์เซอร์จะจำไว้ให้เอง
  `https://<username>.github.io/webapp/?agent=https://<worker>.workers.dev/chat`
- หรือใน DevTools console: `localStorage.setItem('cko-agent-url','https://<worker>.workers.dev/chat')`
- **หรือฝังถาวรในเว็บ:** แก้ค่า `AGENT_PROXY_URL_DEFAULT` ที่ต้นสคริปต์ของ `webapp-source/check-kon-oon.html`
  (ดูคอมเมนต์กำกับ) แล้วคัดลอกทับ `docs/webapp/index.html` ด้วย `cp webapp-source/check-kon-oon.html docs/webapp/index.html`

จากนั้นกลับไปที่ `wrangler.toml` แก้ `ALLOWED_ORIGIN` ให้ตรงกับโดเมนเว็บไซต์จริง (แทน `"*"` เช่น
`https://<username>.github.io`) แล้ว `wrangler deploy` อีกครั้ง เพื่อกันเว็บอื่นเรียกใช้ worker ของคุณฟรี

## ทดสอบว่า worker ทำงานถูกต้อง

```bash
curl -X POST https://check-kon-oon-agent-proxy.<your-subdomain>.workers.dev/chat \
  -H "Content-Type: application/json" \
  -d '{"messages":[{"role":"user","content":"สวัสดีครับ ทดสอบระบบ"}]}'
```

หากตั้งค่าถูกต้องจะได้ผลลัพธ์ `{"reply": "..."}` กลับมา หากได้ `{"error": "not_configured", ...}` แปลว่า
ยังไม่ได้ตั้ง secret ให้ครบ หากได้ `{"error": "upstream_error", ...}` แปลว่า key หรือ URL ที่ตั้งไว้ยังไม่ถูกต้อง
กรุณากลับไปตรวจสอบกับผู้ให้บริการ endpoint นั้นโดยตรง

## ค่าใช้จ่าย

Cloudflare Workers มีแพ็กเกจฟรีให้ 100,000 request/วัน ซึ่งเพียงพอสำหรับการใช้งานจริงของโปรเจกต์นี้
ค่าใช้จ่ายที่อาจเกิดขึ้นจริงคือค่าบริการของ upstream LLM API เอง (ขึ้นกับผู้ให้บริการที่คุณเลือกใช้)
