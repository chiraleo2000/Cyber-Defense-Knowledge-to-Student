# Agent Proxy — วิธี Deploy

Worker นี้ทำหน้าที่เป็น "ตัวกลาง" ระหว่างเว็บแอปกับบริการ LLM (Pathumma หรือบริการอื่นที่ใช้ API key
เดียวกัน) เพื่อไม่ให้ API key รั่วไหลออกไปฝั่ง client — **จำเป็นต้อง deploy ก่อน** ฟีเจอร์ "ผู้ช่วย AI"
ในเว็บแอปจึงจะใช้งานได้ (ถ้าไม่ deploy เว็บแอปจะยังใช้งานได้ปกติทุกส่วน ยกเว้นฟีเจอร์แชทกับผู้ช่วย AI
ซึ่งจะแสดงข้อความแจ้งว่ายังไม่พร้อมใช้งาน แทนที่จะ error)

## ก่อนเริ่ม: เรื่องสำคัญเกี่ยวกับ Pathumma API key

จากการตรวจสอบ ณ ตอนที่จัดทำโปรเจกต์นี้ **Pathumma (ของ NECTEC) เป็นชุดโมเดลโอเพนซอร์สที่เผยแพร่ให้
"self-host" เอง** ผ่านเครื่องมืออย่าง llama.cpp, vLLM หรือ Ollama — ไม่พบ API สาธารณะที่เปิดให้เรียกผ่าน
อินเทอร์เน็ตได้ทันทีแบบ ChatGPT API ดังนั้น **API key ที่คุณมี อาจไม่ได้ผูกกับ endpoint สาธารณะใดๆ** เลย

**แนะนำให้ทดสอบ key ก่อน deploy จริง** โดยลองยิง request ตรงด้วย Postman หรือ curl ไปยัง endpoint ที่คุณ
คิดว่า key นี้ใช้ได้ (เช่นบริการที่ให้ key มา) หากได้ผลลัพธ์กลับมาถูกต้อง ค่อยนำ URL และ key นั้นมาตั้งค่า
worker นี้ตามขั้นตอนด้านล่าง

หากไม่มี endpoint ที่ยืนยันได้ อีกทางเลือกคือ **self-host โมเดล Pathumma เอง** บนเซิร์ฟเวอร์ที่มี GPU
เพียงพอ (ดูวิธีที่ [huggingface.co/nectec](https://huggingface.co/nectec)) แล้วรันผ่าน vLLM หรือ Ollama
ในโหมด OpenAI-compatible API จากนั้นนำ URL เซิร์ฟเวอร์ของคุณเองมาตั้งค่าแทน

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

1. เปิดไฟล์เว็บแอป (`webapp/check-kon-oon.html` หรือหน้า Agent บนเว็บแอปเวอร์ชันที่เผยแพร่)
2. มองหาค่า `AGENT_PROXY_URL` ที่ต้นไฟล์ (ดูคอมเมนต์กำกับไว้ชัดเจน)
3. แก้ไขให้เป็น URL ของ worker ที่ได้จากขั้นตอนก่อนหน้า แล้วบันทึก/เผยแพร่ใหม่
4. กลับไปที่ `wrangler.toml` แก้ `ALLOWED_ORIGIN` ให้ตรงกับโดเมนเว็บไซต์จริงของคุณ (แทน `"*"`) แล้ว
   `wrangler deploy` อีกครั้ง เพื่อป้องกันไม่ให้เว็บไซต์อื่นเรียกใช้ worker ของคุณฟรี

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
