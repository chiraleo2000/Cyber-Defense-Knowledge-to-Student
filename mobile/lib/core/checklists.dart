/// Checklist / quiz items — ported from webapp-source/check-kon-oon.html.

class ChecklistItem {
  const ChecklistItem({
    required this.question,
    required this.weight,
    this.hint,
    this.icon,
    this.gotoRoutes = const [],
  });

  final String question;
  final int weight;
  final String? hint;
  final String? icon;
  final List<String> gotoRoutes;
}

const List<ChecklistItem> kQuizItems = [
  ChecklistItem(
    question: 'มีคนโทรมาอ้างเป็นเจ้าหน้าที่ราชการ ตำรวจ หรือค่ายมือถือ',
    weight: 8,
    icon: 'badge',
    gotoRoutes: ['scan'],
  ),
  ChecklistItem(
    question:
        'เมื่อขอเลขที่คดีหรือเอกสารยืนยันตัวตน ฝ่ายตรงข้ามให้ไม่ได้หรือหลบเลี่ยง',
    weight: 10,
    icon: 'doc',
    gotoRoutes: ['image'],
  ),
  ChecklistItem(
    question: 'ถูกสั่งให้เปิดวิดีโอคอลค้างไว้เป็นเวลานาน',
    weight: 10,
    icon: 'video',
    gotoRoutes: ['video'],
  ),
  ChecklistItem(
    question: 'ถูกสั่งห้ามบอกพ่อแม่ เพื่อน หรืออาจารย์ พร้อมข่มขู่',
    weight: 14,
    icon: 'mute',
    gotoRoutes: ['voice', 'help'],
  ),
  ChecklistItem(
    question: 'ถูกขอให้โอนเงินเข้าบัญชีเพื่อ "ตรวจสอบ" หรือ "บัญชีกลาง"',
    weight: 16,
    icon: 'money',
    gotoRoutes: ['scan'],
  ),
  ChecklistItem(
    question: 'ถูกสั่งให้คุยต่อใน Telegram หรือห้องแชทชื่อ "ห้องสอบสวน"',
    weight: 40,
    icon: 'chat',
    gotoRoutes: ['scan', 'video'],
  ),
  ChecklistItem(
    question: 'ถูกสั่งให้ย้ายออกจากที่พัก เช่าห้องรายวัน หรือเปลี่ยนเบอร์โทร',
    weight: 40,
    icon: 'mute',
    gotoRoutes: ['help'],
  ),
  ChecklistItem(
    question: 'ถูกขอรหัสยืนยัน (OTP) ของ LINE หรือแอปอื่น',
    weight: 60,
    icon: 'ban',
    gotoRoutes: ['help', 'scan'],
  ),
  ChecklistItem(
    question:
        'ถูกสั่งให้สร้างภาพว่าถูกทำร้ายหรือถูกกักขัง เพื่อให้ครอบครัวโอนเงิน',
    weight: 70,
    icon: 'cash',
    gotoRoutes: ['help', 'image'],
  ),
  ChecklistItem(
    question: 'ถูกขอให้ถอนเงินสดหรือนำเงินไปส่งให้คนแปลกหน้า',
    weight: 16,
    icon: 'cash',
    gotoRoutes: ['help'],
  ),
  ChecklistItem(
    question: 'รู้สึกถูกเร่งรัดกดดันให้ตัดสินใจอย่างรวดเร็ว',
    weight: 8,
    icon: 'clock',
    gotoRoutes: ['help'],
  ),
  ChecklistItem(
    question: 'ฝ่ายตรงข้ามย้ำว่าเรื่องนี้เป็น "ความลับที่สุด" ห้ามปรึกษาใคร',
    weight: 8,
    icon: 'mute',
    gotoRoutes: ['voice'],
  ),
  ChecklistItem(
    question:
        'ฝ่ายตรงข้ามปฏิเสธให้คุณโทรกลับยืนยันผ่านเบอร์ทางการของหน่วยงาน',
    weight: 6,
    icon: 'ban',
    gotoRoutes: ['video'],
  ),
  ChecklistItem(
    question:
        '(กรณีความสัมพันธ์ออนไลน์) คู่สนทนาที่ไม่เคยเจอตัวจริงขอยืมเงินหรือชวนลงทุน',
    weight: 4,
    icon: 'heart',
    gotoRoutes: ['romance', 'invest'],
  ),
  ChecklistItem(
    question:
        'ถูกชวนทำงานเสริมออนไลน์ (กดไลก์/ดูคลิป/แพ็กของ) แล้วต้องโอนเงินก่อนหรือโอนเพิ่มเพื่อ "ปลดล็อก"',
    weight: 16,
    icon: 'money',
    gotoRoutes: ['scan', 'invest'],
  ),
  ChecklistItem(
    question:
        'ถูกชวนลงทุนคริปโต/สินทรัพย์ดิจิทัลที่การันตีกำไรสูง หรือกดดันให้โอนเพิ่มก่อนถอนได้',
    weight: 14,
    icon: 'chart',
    gotoRoutes: ['invest', 'scan'],
  ),
];

const List<ChecklistItem> kVideoItems = [
  ChecklistItem(
    question: 'ใช้แอปส่วนตัว เช่น LINE, Facetime, Telegram แทนช่องทางราชการ',
    weight: 20,
  ),
  ChecklistItem(
    question: 'พื้นหลัง แสง หรือมุมกล้องดูจัดฉากไม่เป็นธรรมชาติ',
    weight: 15,
  ),
  ChecklistItem(
    question: 'มีเสียงวิทยุสื่อสาร (เสียง ว.) แทรกแต่ฟังดูเหมือนเสียงประกอบ',
    weight: 10,
  ),
  ChecklistItem(
    question:
        'เอกสารราชการที่ส่งมาไม่มีเลขที่หนังสือหรือลายเซ็นที่ตรวจสอบได้',
    weight: 20,
  ),
  ChecklistItem(
    question: 'ปฏิเสธแจ้งเลขคดี หรือไม่ยอมให้โทรกลับเบอร์กลางของหน่วยงาน',
    weight: 20,
  ),
  ChecklistItem(
    question: 'บังคับห้ามวางสาย ห้ามปิดกล้อง หรือห้ามคุยกับคนอื่นระหว่างสาย',
    weight: 15,
  ),
];

const List<ChecklistItem> kRomanceItems = [
  ChecklistItem(
    question: 'พัฒนาความสัมพันธ์รวดเร็วผิดปกติ ทุ่มเทคำหวานภายในไม่กี่วัน',
    weight: 20,
  ),
  ChecklistItem(
    question: 'ปฏิเสธหรือหาข้ออ้างไม่ยอมวิดีโอคอลสดหรือนัดเจอตัวจริง',
    weight: 20,
  ),
  ChecklistItem(
    question:
        'อ้างว่าทำงานหรืออาศัยอยู่ต่างประเทศ (แท่นขุดเจาะ ทหาร วิศวกรโครงการต่างแดน)',
    weight: 20,
  ),
  ChecklistItem(
    question: 'มีเหตุฉุกเฉินกะทันหันและขอให้ช่วยเหลือทางการเงิน',
    weight: 20,
  ),
  ChecklistItem(
    question:
        'ขอให้โอนเงินผ่านช่องทางที่ตรวจสอบยาก หรือชวนให้ช่วย "ลงทุน" แทน',
    weight: 20,
  ),
];

const List<ChecklistItem> kInvestItems = [
  ChecklistItem(
    question: 'การันตีผลตอบแทนสูงคงที่ในเวลาสั้น โดยไม่มีความเสี่ยง',
    weight: 18,
  ),
  ChecklistItem(
    question:
        'ชักชวนผ่านแอปหรือแพลตฟอร์มที่ไม่รู้จัก หรือไม่ได้รับอนุญาตจาก ก.ล.ต./ธปท.',
    weight: 16,
  ),
  ChecklistItem(
    question: 'ให้เห็นกำไรก้อนแรกอย่างรวดเร็วเพื่อสร้างความเชื่อใจ',
    weight: 16,
  ),
  ChecklistItem(
    question: 'กดดันให้ลงทุนเพิ่มเรื่อยๆ หรือชวนเพื่อน/ครอบครัวมาร่วมลงทุน',
    weight: 16,
  ),
  ChecklistItem(
    question: 'เริ่มถอนเงินไม่ได้ หรือมีข้ออ้างเรื่อยๆ เมื่อขอถอนเงินคืน',
    weight: 18,
  ),
  ChecklistItem(
    question:
        'ชวนลงทุนคริปโต/สินทรัพย์ดิจิทัล พร้อมกดดันว่าต้องโอนเพิ่มเพื่อปลดล็อกหรือถอนกำไร',
    weight: 16,
  ),
];

const List<ChecklistItem> kImageItems = [
  ChecklistItem(
    question: 'ไม่มีเลขที่หนังสือ ตราครุฑ หรือลายเซ็นที่ตรวจสอบย้อนกลับได้',
    weight: 25,
  ),
  ChecklistItem(
    question: 'ใช้ฟอนต์ไม่สม่ำเสมอ มีคำสะกดผิด หรือจัดวางไม่เป็นทางการ',
    weight: 20,
  ),
  ChecklistItem(
    question:
        'เป็นภาพหน้าจอแอปแชทส่วนตัว ไม่ใช่ระบบหรือแอปทางการของหน่วยงาน',
    weight: 20,
  ),
  ChecklistItem(
    question: 'ไม่มีวันที่ เวลา หรือหมายเลขอ้างอิงที่ตรวจสอบได้',
    weight: 15,
  ),
  ChecklistItem(
    question: 'ตรา สัญลักษณ์ หรือโลโก้เบลอ ไม่คมชัด เหมือนถูกตัดแปะ',
    weight: 20,
  ),
];

const Map<String, String> kPageLabels = {
  'quiz': 'หน้าแรก',
  'video': 'ตรวจสอบวิดีโอคอล',
  'image': 'ตรวจสอบภาพ/เอกสาร',
  'scan': 'สแกนข้อความ',
  'voice': 'ถอดเสียงสนทนา',
  'romance': 'Romance Scam',
  'invest': 'หลอกลงทุน',
  'help': 'ขอความช่วยเหลือ',
  'agent': 'ผู้ช่วย AI',
  'guardian': 'ผู้พิทักษ์สาย (ทดลอง)',
};

class TriageTile {
  const TriageTile({
    required this.route,
    required this.label,
    required this.hint,
    required this.icon,
  });

  final String route;
  final String label;
  final String hint;
  final String icon;
}

const List<TriageTile> kTriageTiles = [
  TriageTile(
    route: 'scan',
    label: 'ได้รับข้อความ/แชทที่น่าสงสัย',
    hint: 'สแกนคำเสี่ยง เช่น บัญชีกลาง ห้องสอบสวน',
    icon: 'chat',
  ),
  TriageTile(
    route: 'video',
    label: 'กำลังอยู่ในวิดีโอคอลที่น่าสงสัย',
    hint: 'ตรวจสอบว่าเป็นการจัดฉากหรือไม่',
    icon: 'video',
  ),
  TriageTile(
    route: 'image',
    label: 'ได้รับภาพ/เอกสารอ้างเป็นทางการ',
    hint: 'ตรวจ EXIF และเกณฑ์เอกสารปลอม',
    icon: 'doc',
  ),
  TriageTile(
    route: 'voice',
    label: 'ได้ยินบทสนทนาแล้วอยากถอดเสียง',
    hint: 'ใช้ไมโครโฟนระบบแล้วสแกนข้อความ',
    icon: 'mic',
  ),
  TriageTile(
    route: 'romance',
    label: 'คนรักออนไลน์ที่ไม่เคยเจอตัวขอเงิน',
    hint: 'เช็คสัญญาณ Romance Scam',
    icon: 'heart',
  ),
  TriageTile(
    route: 'invest',
    label: 'ถูกชวนลงทุนผลตอบแทนสูงเกินจริง',
    hint: 'เช็คสัญญาณหลอกลงทุน',
    icon: 'chart',
  ),
  TriageTile(
    route: 'help',
    label: 'ต้องการความช่วยเหลือด่วน',
    hint: 'โทร 1441 / 191 / 1599 ได้ทันที',
    icon: 'help',
  ),
  TriageTile(
    route: 'agent',
    label: 'ถามผู้ช่วย AI',
    hint: 'ออฟไลน์ได้ หรือตั้งค่า Pathumma worker',
    icon: 'chat',
  ),
];
