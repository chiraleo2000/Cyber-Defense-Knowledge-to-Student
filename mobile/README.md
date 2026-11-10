# เช็คก่อนโอน (`check_before_transfer`)

แอป Flutter (Android + iOS) สำหรับ **หยุดก่อนเงินออกจากบัญชี** — พอร์ตเครื่องมือจากเว็บแอป `webapp-source/check-kon-oon.html` / `docs/webapp/`

## สถานะตาม Roadmap

| เฟส | ขอบเขต | สถานะในโฟลเดอร์นี้ |
|---|---|---|
| **Phase 1** | Quiz, สแกนข้อความ, วิดีโอ, ภาพ/EXIF, Romance, ลงทุน, Help/SOS, disclaimer, privacy baseline | ✅ โค้ดพร้อม |
| **Phase 1.5** | Native STT → สแกนเดียวกัน + ผู้ช่วย AI (Pathumma worker ทางเลือก + ออฟไลน์) | ✅ โค้ดพร้อม |
| **Phase 2** | ผู้พิทักษ์สาย (realtime call) | 🧪 **scaffold ทดลองเท่านั้น** — opt-in, **ไม่ตัดสายอัตโนมัติ** |

อย่าสับสน: หน้า `/guardian` เป็นโครงแนวคิด ไม่ได้เชื่อมสายโทรจริง

## ความเป็นส่วนตัว

- สแกนข้อความ / checklist / EXIF ทำงานบนเครื่อง
- ไม่ถามและไม่เก็บเลขบัตรประชาชน / เลขบัญชี / OTP
- ไม่เก็บประวัติสแกนถาวร
- STT ใช้ Speech-to-Text ของระบบ (ไม่ส่งเสียงขึ้นคลาวด์ในโหมดนี้)
- ผู้ช่วย AI ส่งเฉพาะข้อความที่ผู้ใช้พิมพ์ เมื่อตั้งค่า worker URL เท่านั้น

## วิธีรัน

ต้องมี [Flutter SDK](https://docs.flutter.dev/get-started/install) (ทดสอบกับ stable)

```bash
cd mobile
flutter pub get
flutter test
flutter run
```

Deep links ในแอป (go_router): `/quiz`, `/scan`, `/help` (+ โมดูลอื่น)  
สคีมตัวอย่าง: `checkbeforetransfer://scan`

ตั้งค่า Pathumma: เปิดแท็บ AI แล้วใส่ worker URL (เช่น `https://…workers.dev/chat`) — ดู `../worker/README.md`  
หมายเหตุ CORS: เบราว์เซอร์ต้องอนุญาต origin; แอป native ใช้ HTTP โดยตรงแต่ควร rate-limit ตาม worker

## ซิงก์กฎกับเว็บแอป (สำคัญ)

แหล่งความจริงของน้ำหนัก/LEXICON คือ **`webapp-source/check-kon-oon.html`**

สำเนาที่แชร์:

1. `../shared/scam-rules.json` — JSON ร่วมสำหรับอ้างอิง/ซิงก์
2. `assets/scam-rules.json` — สำเนาในแอป
3. `lib/core/lexicon.dart` + `lib/core/checklists.dart` + `lib/core/scoring.dart` — ฝังใน Dart เพื่อออฟไลน์และ unit test

**เช็คลิสต์เมื่อแก้กฎบนเว็บ:**

1. อัปเดต LEXICON / quiz weights ใน `check-kon-oon.html` (แล้ว sync `docs/webapp/`)
2. คัดลอกเข้า `shared/scam-rules.json` และ `mobile/assets/scam-rules.json`
3. อัปเดต Dart ใน `lib/core/` ให้ตรง
4. รัน `flutter test` ใน `mobile/`
5. ใส่การเปลี่ยนกฎเว็บ+มือถือใน PR เดียวกันเมื่อทำได้

## โครงสร้างหลัก

```
lib/core/          scoring, LEXICON, checklists, EXIF, offline AI
lib/screens/       quiz, scan, video, image, voice, romance, invest, help, agent, guardian
lib/services/      STT + Pathumma worker client
test/              lexicon / quiz fixtures / offline AI
```

## ติดตั้ง Flutter ถ้ายังไม่มี (Windows)

```powershell
git clone https://github.com/flutter/flutter.git -b stable $env:LOCALAPPDATA\flutter
$env:PATH = "$env:LOCALAPPDATA\flutter\bin;$env:PATH"
flutter doctor
```

ในเครื่องที่ scaffold นี้ เคยใช้ `D:\flutter` เป็นทางเลือกชั่วคราว — ตั้ง PATH ตามเครื่องคุณ
