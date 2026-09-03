# tools/ — สคริปต์ช่วยดูแลโปรเจกต์

## build_pdfs.py — สร้างไฟล์ PDF ภาษาไทยจากไฟล์ Markdown

สร้างไฟล์ PDF (ชื่อภาษาไทยตรงกับไฟล์ `.md`) ลงในโฟลเดอร์ `docs/downloads/`
โดยใช้ Chrome หรือ Edge แบบ headless (`--print-to-pdf`) ซึ่งรองรับการเรนเดอร์ภาษาไทยได้ดี
และฝังฟอนต์ Sarabun (self-hosted) เป็น base64 เพื่อให้ผลลัพธ์เหมือนกันทุกเครื่อง

### ต้องมีก่อนใช้งาน

- Python 3 + แพ็กเกจ `markdown` — ติดตั้งด้วย `pip install markdown`
- ติดตั้ง Google Chrome หรือ Microsoft Edge อย่างใดอย่างหนึ่ง (สคริปต์ค้นหาให้อัตโนมัติ)

### วิธีใช้

```bash
# สร้าง PDF ทุกหน้าใหม่ทั้งหมด
python tools/build_pdfs.py

# สร้างเฉพาะหน้าเดียว (ระบุชื่อไฟล์ .md ในโฟลเดอร์ docs/content/)
python tools/build_pdfs.py "ถูกหลอกแล้วทำอย่างไร.md"
```

> ทุกครั้งที่แก้ไขเนื้อหาไฟล์ `.md` ในโฟลเดอร์ `docs/content/` ให้รันสคริปต์นี้ใหม่
> เพื่อให้ไฟล์ PDF ตรงกับเนื้อหาล่าสุด แล้ว commit ไฟล์ PDF ที่อัปเดตไปพร้อมกัน

## selfhost-pathumma.ps1 — โฮสต์ Pathumma เองด้วย vLLM

ทางเลือกถ้าไม่ใช้ผู้ให้บริการภายนอก (เช่น Featherless) ต้องมี Docker + GPU NVIDIA
และ `cloudflared` ถ้าต้องการให้ Cloudflare Worker เรียกได้จากอินเทอร์เน็ต

```powershell
powershell -File .\tools\selfhost-pathumma.ps1          # รันเฉพาะในเครื่อง
powershell -File .\tools\selfhost-pathumma.ps1 -Tunnel  # + เปิด HTTPS สาธารณะ
```

รายละเอียดการตั้ง `UPSTREAM_BASE_URL` ดูที่ `worker/README.md`
