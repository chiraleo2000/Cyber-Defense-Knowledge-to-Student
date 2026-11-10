class Hotline {
  const Hotline({
    required this.number,
    required this.name,
  });

  final String number;
  final String name;

  Uri get telUri => Uri(scheme: 'tel', path: number);
}

const List<Hotline> kHotlines = [
  Hotline(
    number: '1441',
    name: 'AOC ศูนย์ปฏิบัติการแก้ไขปัญหาอาชญากรรมออนไลน์',
  ),
  Hotline(
    number: '191',
    name: 'แจ้งเหตุด่วนตำรวจ',
  ),
  Hotline(
    number: '1599',
    name: 'สายด่วนตำรวจไซเบอร์ (บช.สอท.)',
  ),
];

const String kDisclaimerText =
    'เครื่องมือนี้เป็นการประเมินเบื้องต้นเพื่อช่วยตั้งข้อสังเกตเท่านั้น ไม่ใช่คำตัดสินขั้นสุดท้าย — '
    'หากกำลังอยู่ในสถานการณ์ที่รู้สึกไม่ปลอดภัยหรือถูกกดดัน ให้หยุดทำรายการทันที วางสาย '
    'แล้วโทรสายด่วน AOC 1441 หรือแจ้งความที่สถานีตำรวจใกล้บ้านก่อนตัดสินใจใดๆ';

const String kPrivacyBaseline =
    'แอปนี้ประมวลผลข้อความ/ภาพบนเครื่องเป็นหลัก ไม่ถามเลขบัตรประชาชน เลขบัญชี หรือ OTP '
    'และไม่เก็บประวัติการสแกนถาวร — ผู้ช่วย AI (ถ้าตั้งค่า worker) จะส่งเฉพาะข้อความที่คุณพิมพ์ไปยัง '
    'Pathumma ผ่าน Cloudflare Worker ตามที่ตั้งค่าไว้เท่านั้น';
