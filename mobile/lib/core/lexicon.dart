/// Message scanner LEXICON — ported from webapp-source/check-kon-oon.html.
/// Keep in sync with ../../shared/scam-rules.json and the webapp LEXICON array.

class LexiconCategory {
  const LexiconCategory({
    required this.key,
    required this.weight,
    required this.words,
  });

  final String key;
  final int weight;
  final List<String> words;
}

class ScanHit {
  const ScanHit({
    required this.start,
    required this.end,
    required this.categoryKey,
    required this.word,
  });

  final int start;
  final int end;
  final String categoryKey;
  final String word;

  int get length => end - start;
}

class ScanResult {
  const ScanResult({
    required this.score,
    required this.hits,
    required this.categoriesHit,
  });

  final int score;
  final List<ScanHit> hits;
  final Set<String> categoriesHit;
}

const List<LexiconCategory> kLexicon = [
  LexiconCategory(
    key: 'authority',
    weight: 15,
    words: [
      'ปปง.',
      'ดีเอสไอ',
      'DSI',
      'สภ.เมืองเลย',
      'บก.สอท',
      'หมายจับ',
      'หมายศาล',
      'เจ้าหน้าที่ AIS',
      'สำนักงานใหญ่',
      'ตำรวจไซเบอร์',
      'กรมสอบสวนคดีพิเศษ',
      'ห้องสอบสวน',
      'Telegram',
      'เทเลแกรม',
    ],
  ),
  LexiconCategory(
    key: 'threat',
    weight: 20,
    words: [
      'คดีฟอกเงิน',
      'ฟอกเงิน',
      'ยาเสพติด',
      'เว็บพนัน',
      'อายัดบัญชี',
      'ความลับที่สุด',
      'ดำเนินคดี',
      'จับกุม',
      'ค่าไถ่',
      'คราบเลือด',
    ],
  ),
  LexiconCategory(
    key: 'control',
    weight: 20,
    words: [
      'ห้ามวางสาย',
      'ห้ามบอก',
      'ห้ามปิดกล้อง',
      'ห้ามแคปหน้าจอ',
      'ห้ามคุยกับใคร',
      'ห้ามปรึกษา',
      'เปลี่ยนเบอร์',
      'เช่าห้องรายวัน',
      'ย้ายออกจากที่พัก',
      'รหัสยืนยัน',
    ],
  ),
  LexiconCategory(
    key: 'money',
    weight: 25,
    words: [
      'บัญชีกลาง',
      'โอนเงินตรวจสอบ',
      'เงินประกันตัว',
      'ทุนการศึกษา',
      'ทุนเรียนต่อ',
      'โอนยืนยัน',
      'พิสูจน์ความบริสุทธิ์',
    ],
  ),
  LexiconCategory(
    key: 'handoff',
    weight: 20,
    words: [
      'ถอนเงินสด',
      'รับที่คอนโด',
      'รับที่โรงแรม',
      'รหัสลับ',
      'ม้าเร็ว',
      'ส่งเงินสด',
    ],
  ),
  // งานเสริม/คริปโต — น้ำหนักแยก ไม่ไปลดน้ำหนัก Telegram / OTP / ค่าไถ่
  LexiconCategory(
    key: 'job',
    weight: 18,
    words: [
      'งานเสริม',
      'กดไลก์',
      'ปลดล็อกระบบ',
      'ปลดล็อก',
      'เปิดระบบ',
      'ค่าภารกิจ',
      'เงินสำรอง',
      'โอนก่อนทำงาน',
      'ทำภารกิจ',
    ],
  ),
  LexiconCategory(
    key: 'crypto',
    weight: 18,
    words: [
      'คริปโต',
      'คริปโตเคอร์เรนซี',
      'สินทรัพย์ดิจิทัล',
      'กำไรการันตี',
      'การันตีกำไร',
      'ผลตอบแทนการันตี',
      'กำไรแน่นอน',
    ],
  ),
];

/// Same scoring/highlight rules as webapp `runScanOn`.
ScanResult scanMessage(String raw, {List<LexiconCategory> lexicon = kLexicon}) {
  if (raw.trim().isEmpty) {
    return const ScanResult(score: 0, hits: [], categoriesHit: {});
  }

  final spans = <ScanHit>[];
  final categoriesHit = <String>{};
  var score = 0;

  for (final cat in lexicon) {
    var catHit = false;
    for (final word in cat.words) {
      var idx = raw.indexOf(word);
      while (idx != -1) {
        spans.add(ScanHit(
          start: idx,
          end: idx + word.length,
          categoryKey: cat.key,
          word: word,
        ));
        catHit = true;
        idx = raw.indexOf(word, idx + 1);
      }
    }
    if (catHit) {
      score += cat.weight;
      categoriesHit.add(cat.key);
    }
  }
  if (score > 100) score = 100;

  // Longest-first, drop overlaps (same as webapp).
  spans.sort((a, b) => b.length.compareTo(a.length));
  final chosen = <ScanHit>[];
  for (final s in spans) {
    final overlaps = chosen.any((c) => s.start < c.end && c.start < s.end);
    if (!overlaps) chosen.add(s);
  }
  chosen.sort((a, b) => a.start.compareTo(b.start));

  return ScanResult(score: score, hits: chosen, categoriesHit: categoriesHit);
}
