# คู่มือเปิดใช้งาน Agent (ผู้ช่วย AI Pathumma) แบบเต็มระบบ

เอกสารนี้อธิบายการเปิดฟีเจอร์ "ผู้ช่วย AI" ในเว็บแอปให้ตอบด้วยโมเดลภาษาไทย **Pathumma (NECTEC)** จริง
(ถ้ายังไม่ทำ เว็บแอปยังใช้งานได้ทุกส่วน เพียงแต่ผู้ช่วย AI จะตอบแบบออฟไลน์/กฎเบื้องต้นแทน)

---

## ทำไมต้องมี Cloudflare Worker (ฝังใน GitHub Pages อย่างเดียวไม่ได้)

GitHub Pages เสิร์ฟได้แค่ไฟล์ static (HTML/CSS/JS) — **รันโค้ดฝั่งเซิร์ฟเวอร์ไม่ได้** และ
**เก็บความลับไม่ได้** (ใครเปิด View Source ก็เห็นทุกอย่าง)

การเรียกโมเดล Pathumma ต้องใช้ **API key** ถ้าเอา key ไปฝังในหน้าเว็บบน Pages ตรง ๆ key จะรั่ว
ให้คนอื่นเอาไปใช้ฟรีได้ทันที เราจึงใช้ **Cloudflare Worker เป็นตัวกลาง**:

```
เบราว์เซอร์ (หน้าเว็บบน GitHub Pages)
        │  ส่งข้อความแชท (ไม่มี key)
        ▼
Cloudflare Worker  ← เก็บ API key ไว้ที่นี่ (ปลอดภัย มองไม่เห็นจาก client)
        │  แนบ key แล้วเรียกต่อ
        ▼
Pathumma API (Featherless / self-host)
```

Cloudflare Worker มีแพ็กเกจฟรี 100,000 request/วัน เพียงพอสำหรับโปรเจกต์นี้

---

## เตรียมของ 4 อย่าง

1. **บัญชี Cloudflare** (ฟรี) — https://www.cloudflare.com
2. **API key ของผู้ให้บริการที่โฮสต์ Pathumma** เช่น [Featherless.ai](https://featherless.ai)
   (สมัครแล้วสร้าง API key ที่ https://featherless.ai/account/api-keys)
3. **UPSTREAM_BASE_URL** เช่น `https://api.featherless.ai/v1` (ไม่ต้องมี `/chat/completions` ต่อท้าย)
4. **ชื่อโมเดล** — ตั้งไว้แล้วใน `worker/wrangler.toml`: `nectec/Pathumma-llm-text-1.0.0`
   (เปลี่ยนเป็น `nectec/thai-research-gemma-3-27b-it` ได้ถ้าต้องการโมเดลใหญ่กว่า)

---

## ขั้นตอนที่ 1 — Deploy Worker

เลือกทางใดทางหนึ่ง

### ทาง A: ผ่าน GitHub Actions (ไม่ต้องลงอะไรบนเครื่อง — แนะนำ)

1. ไปที่ repo → **Settings → Secrets and variables → Actions → New repository secret**
   เพิ่ม 4 ค่า:
   | ชื่อ Secret | ค่า |
   |---|---|
   | `CLOUDFLARE_API_TOKEN` | API Token จาก Cloudflare (สิทธิ์ *Edit Cloudflare Workers*) |
   | `CLOUDFLARE_ACCOUNT_ID` | Account ID จากแดชบอร์ด Cloudflare |
   | `UPSTREAM_API_KEY` | API key ของผู้ให้บริการ Pathumma |
   | `UPSTREAM_BASE_URL` | เช่น `https://api.featherless.ai/v1` |
2. ไปแท็บ **Actions → Deploy Cloudflare Worker → Run workflow**
3. รอจนเสร็จ URL ของ Worker จะอยู่ใน log (เช่น `https://check-kon-oon-agent-proxy.<subdomain>.workers.dev`)

> วิธีหา Cloudflare API Token: แดชบอร์ด Cloudflare → My Profile → API Tokens → Create Token →
> ใช้เทมเพลต **Edit Cloudflare Workers**  ส่วน Account ID อยู่หน้า Workers & Pages (คอลัมน์ขวา)

### ทาง B: รันบนเครื่อง Windows

```powershell
cd worker
powershell -File .\deploy.ps1
```
สคริปต์จะพาคุณ login Cloudflare, ใส่ `UPSTREAM_API_KEY` / `UPSTREAM_BASE_URL` แล้ว deploy ให้
(ต้องมี Node.js — ถ้ายังไม่มี: `winget install OpenJS.NodeJS.LTS`)

---

## ขั้นตอนที่ 2 — ชี้เว็บแอปไปที่ Worker

เปิดลิงก์นี้ **ครั้งเดียว** (เบราว์เซอร์จะจำ URL ไว้ใน localStorage เอง แทนที่ `<worker>` ด้วยของจริง):

```
https://chiraleo2000.github.io/Cyber-Defense-Knowledge-to-Student/webapp/?agent=https://<worker>.workers.dev/chat
```

เข้าไปหน้า "ผู้ช่วย AI" ถ้าเชื่อมสำเร็จจะขึ้นข้อความ **"เชื่อมต่อผู้ช่วย AI (Pathumma) สำเร็จ"**

---

## ทดสอบและเก็บงานให้เรียบร้อย

- ทดสอบ Worker ตรง ๆ: `powershell -File worker\test-chat.ps1 -WorkerUrl https://<worker>.workers.dev`
  หรือ curl:
  ```bash
  curl -X POST https://<worker>.workers.dev/chat \
    -H "Content-Type: application/json" \
    -d '{"messages":[{"role":"user","content":"สวัสดี ทดสอบระบบ"}]}'
  ```
  ได้ `{"reply":"..."}` = สำเร็จ / ได้ `{"error":"not_configured"}` = ยังตั้ง secret ไม่ครบ /
  ได้ `{"error":"upstream_error"}` = key หรือ URL ยังไม่ถูกต้อง
- **กันคนอื่นเรียก Worker ฟรี:** แก้ `ALLOWED_ORIGIN` ใน `worker/wrangler.toml` จาก `"*"` เป็น
  `https://chiraleo2000.github.io` แล้ว deploy Worker อีกครั้ง

---

## หมายเหตุเรื่องโมเดล Pathumma

- Pathumma รุ่นใหม่ (เช่น 4.0.0) เป็น reasoning model ที่ใส่ร่องรอยการคิดใน `<think>...</think>` —
  Worker ตัดส่วนนี้ออกให้อัตโนมัติ ส่งเฉพาะคำตอบสุดท้ายกลับมา
- คำตอบจากผู้ช่วยเป็นข้อมูลเบื้องต้นเท่านั้น ไม่ใช่คำวินิจฉัยทางกฎหมายหรือการเงิน
- รายละเอียดเทคนิคเพิ่มเติมดูที่ `worker/README.md`
