# Agent Proxy — วิธี Deploy

Worker นี้ทำหน้าที่เป็น "ตัวกลาง" ระหว่างเว็บแอปกับบริการ LLM (Pathumma หรือบริการอื่นที่ใช้ API
แบบ OpenAI-compatible) เพื่อไม่ให้ API key รั่วไหลออกไปฝั่ง client — **จำเป็นต้อง deploy ก่อน**
ฟีเจอร์ "ผู้ช่วย AI" ในเว็บแอปจึงจะใช้งานได้ (ถ้าไม่ deploy เว็บแอปจะยังใช้งานได้ปกติทุกส่วน
ยกเว้นฟีเจอร์แชทกับผู้ช่วย AI ซึ่งจะตอบแบบออฟไลน์/กฎเบื้องต้นแทน)

เว็บไซต์ GitHub Pages ของโปรเจกต์นี้: `https://chiraleo2000.github.io/Cyber-Defense-Knowledge-to-Student/`

## หลังบ้านใช้ Pathumma (ThaiLLM ของ NECTEC)

ผู้ช่วย AI ในเว็บแอปเรียกโมเดลภาษาไทย **Pathumma** ผ่าน worker นี้ Pathumma เป็นโมเดลโอเพนซอร์ส
(ดู [huggingface.co/nectec](https://huggingface.co/nectec)) ที่ใช้งานได้ 2 ทางหลัก โดยทั้งสองทางพูดภาษา
มาตรฐานเดียวกันคือ **OpenAI-compatible Chat Completions** worker นี้จึงเรียกได้โดยไม่ต้องแก้โค้ด:

### ทางที่ 1 (ง่ายสุด): ใช้ ThaiLLM Playground

[ThaiLLM Playground](https://thaillm.or.th) ให้บริการโมเดล Pathumma แบบ OpenAI-compatible:

- `UPSTREAM_BASE_URL` = `http://thaillm.or.th/api/v1`
- `MODEL_NAME` = `pathumma-thaillm-qwen3-8b-think-3.0.0` (ดูรายชื่อทั้งหมดที่ `GET /api/v1/models`)
- `UPSTREAM_API_KEY` = API key จาก ThaiLLM Playground
- โควตา: 5 req/วินาที, 200 req/นาที

### ทางที่ 2: self-host โมเดล Pathumma เอง

มีสคริปต์ช่วยใน `tools/selfhost-pathumma.ps1` (Windows + Docker GPU) — ดูหัวข้อท้ายไฟล์นี้
หรือรันบนเซิร์ฟเวอร์ Linux ที่มี GPU ด้วย vLLM/Ollama แล้วตั้ง `UPSTREAM_BASE_URL` เป็น URL สาธารณะ
(เช่น `https://your-server.example.com/v1`) และ `MODEL_NAME` ตามชื่อโมเดลที่โหลดไว้

> **ทดสอบ key/endpoint ก่อน deploy เสมอ** ด้วยการยิงตรงไป `<UPSTREAM_BASE_URL>/chat/completions`
> เพื่อยืนยันว่าใช้งานได้จริง แล้วค่อยนำมาตั้งค่า worker
>
> **หมายเหตุ:** Pathumma รุ่นใหม่ (เช่น 4.0.0) เป็น reasoning model ที่ใส่ร่องรอยการคิดใน `<think>...</think>`
> worker นี้ตัดส่วนนั้นออกให้อัตโนมัติแล้ว จึงส่งเฉพาะคำตอบสุดท้ายกลับไปที่เว็บแอป

## ขั้นตอน Deploy (เลือกวิธีใดวิธีหนึ่ง)

`ALLOWED_ORIGIN` ใน `wrangler.toml` ล็อกเป็นโดเมน GitHub Pages ของโปรเจกต์นี้แล้ว
(`https://chiraleo2000.github.io`) ไม่ต้อง deploy รอบสองเพื่อปิด `"*"`

### วิธี A — สคริปต์บนเครื่อง Windows (แนะนำถ้ามี Node.js)

ต้องมีบัญชี Cloudflare (สมัครฟรีได้ที่ [cloudflare.com](https://www.cloudflare.com))

```powershell
# ถ้ายังไม่มี Node.js
winget install OpenJS.NodeJS.LTS
# ปิด-เปิดเทอร์มินัล แล้ว:
cd worker
powershell -File .\deploy.ps1
```

สคริปต์จะเปิดเบราว์เซอร์ให้ล็อกอิน Cloudflare แล้วถามคีย์/URL จากนั้น `wrangler deploy`
เมื่อสำเร็จจะได้ URL เช่น `https://check-kon-oon-agent-proxy.<your-subdomain>.workers.dev`

ทำทีละคำสั่งเองก็ได้:

```powershell
cd worker
npx --yes wrangler@4 login
npx --yes wrangler@4 secret put UPSTREAM_API_KEY
npx --yes wrangler@4 secret put UPSTREAM_BASE_URL
npx --yes wrangler@4 deploy
```

### วิธี B — GitHub Actions (ไม่ต้องติดตั้ง Node บนเครื่อง)

1. สร้าง Cloudflare API Token (สิทธิ์ Edit Cloudflare Workers) แล้วคัดลอก Account ID จากแดชบอร์ด
2. ใน GitHub repo ไปที่ **Settings → Secrets and variables → Actions** แล้วเพิ่ม:
   - `CLOUDFLARE_API_TOKEN`
   - `CLOUDFLARE_ACCOUNT_ID`
   - `UPSTREAM_API_KEY`
   - `UPSTREAM_BASE_URL` (`http://thaillm.or.th/api/v1`)
3. ไปที่แท็บ **Actions → Deploy Cloudflare Worker → Run workflow**

## หลัง Deploy: เชื่อมกับเว็บแอป

เปิดครั้งเดียว เบราว์เซอร์จะจำ URL ไว้ใน `localStorage`:

```
https://chiraleo2000.github.io/Cyber-Defense-Knowledge-to-Student/webapp/?agent=https://<worker>.workers.dev/chat
```

ทางเลือกอื่น:

- ใน DevTools console: `localStorage.setItem('cko-agent-url','https://<worker>.workers.dev/chat')`
- **ฝังถาวรในเว็บ:** แก้ค่า `AGENT_PROXY_URL_DEFAULT` ที่ต้นสคริปต์ของ `webapp-source/check-kon-oon.html`
  แล้วคัดลอกทับ `docs/webapp/index.html`

ถ้าต้องการทดสอบเว็บแอปจาก localhost ด้วย ให้เติม origin ใน `wrangler.toml` เช่น
`ALLOWED_ORIGIN = "https://chiraleo2000.github.io,http://localhost:5500"` แล้ว deploy ใหม่

## ทดสอบว่า worker ทำงานถูกต้อง

```powershell
# เปิดในเบราว์เซอร์หรือ:
#   https://<worker>.workers.dev/health
# ควรได้ {"ok":true,"configured":true,...}

cd worker
powershell -File .\test-chat.ps1 -WorkerUrl https://check-kon-oon-agent-proxy.<your-subdomain>.workers.dev
```

หรือด้วย curl:

```bash
curl https://check-kon-oon-agent-proxy.<your-subdomain>.workers.dev/health

curl -X POST https://check-kon-oon-agent-proxy.<your-subdomain>.workers.dev/chat \
  -H "Content-Type: application/json" \
  -d '{"messages":[{"role":"user","content":"สวัสดีครับ ทดสอบระบบ"}]}'
```

หากตั้งค่าถูกต้องจะได้ผลลัพธ์ `{"reply": "..."}` กลับมา หากได้ `{"error": "not_configured", ...}` แปลว่า
ยังไม่ได้ตั้ง secret ให้ครบ หากได้ `{"error": "upstream_error", ...}` แปลว่า key หรือ URL ที่ตั้งไว้ยังไม่ถูกต้อง
กรุณากลับไปตรวจสอบกับผู้ให้บริการ endpoint นั้นโดยตรง

## Self-host Pathumma ด้วย vLLM (ทางเลือก)

Cloudflare Worker **เรียก localhost ของเครื่องคุณไม่ได้** ต้องมี URL สาธารณะ (HTTPS)
สคริปต์ `tools/selfhost-pathumma.ps1` รัน vLLM ใน Docker แล้วเปิด Cloudflare Tunnel ให้:

```powershell
winget install Docker.DockerDesktop
winget install Cloudflare.cloudflared
# เปิด Docker Desktop ให้พร้อม GPU/WSL2 แล้ว:
powershell -File .\tools\selfhost-pathumma.ps1 -Tunnel
```

คัดลอก URL `https://....trycloudflare.com` ที่ cloudflared แสดง แล้วตั้ง

- `UPSTREAM_BASE_URL` = `https://<tunnel-host>/v1`
- `MODEL_NAME` ใน `wrangler.toml` = `nectec/Pathumma-llm-text-1.0.0`

ต้องมี GPU NVIDIA (แนะนำ VRAM 16GB ขึ้นไป) ครั้งแรกจะดาวน์โหลดโมเดลจาก Hugging Face

## ค่าใช้จ่าย

Cloudflare Workers มีแพ็กเกจฟรีให้ 100,000 request/วัน ซึ่งเพียงพอสำหรับการใช้งานจริงของโปรเจกต์นี้
ค่าใช้จ่ายที่อาจเกิดขึ้นจริงคือค่าบริการของ upstream LLM API เอง (ขึ้นกับผู้ให้บริการที่คุณเลือกใช้)
หรือค่าไฟฟ้า/GPU หาก self-host
