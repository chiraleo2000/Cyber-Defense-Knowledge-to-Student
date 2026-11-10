import 'package:check_before_transfer/core/lexicon.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('scanMessage LEXICON', () {
    test('Telegram ห้องสอบสวน hits authority', () {
      final r = scanMessage('ให้เข้า Telegram ห้องสอบสวน เดี๋ยวนี้');
      expect(r.categoriesHit.contains('authority'), isTrue);
      expect(r.score, greaterThanOrEqualTo(15));
      expect(r.hits.any((h) => h.word == 'ห้องสอบสวน'), isTrue);
      expect(r.hits.any((h) => h.word == 'Telegram'), isTrue);
    });

    test('OTP / รหัสยืนยัน hits control', () {
      final r = scanMessage('ส่งรหัสยืนยัน LINE มาให้หน่อย');
      expect(r.categoriesHit.contains('control'), isTrue);
      expect(r.hits.any((h) => h.word == 'รหัสยืนยัน'), isTrue);
    });

    test('บัญชีกลาง + ถอนเงินสด stacks money and handoff', () {
      final r = scanMessage('โอนเข้าบัญชีกลาง แล้วถอนเงินสดไปส่งที่คอนโด');
      expect(r.categoriesHit.contains('money'), isTrue);
      expect(r.categoriesHit.contains('handoff'), isTrue);
      expect(r.score, greaterThanOrEqualTo(45));
    });

    test('overlap keeps longest span (คดีฟอกเงิน vs ฟอกเงิน)', () {
      final r = scanMessage('คุณเกี่ยวข้องคดีฟอกเงิน');
      expect(r.hits.any((h) => h.word == 'คดีฟอกเงิน'), isTrue);
      expect(r.hits.any((h) => h.word == 'ฟอกเงิน'), isFalse);
    });

    test('job scam and crypto phrases add their own weights', () {
      final job = scanMessage('ชวนงานเสริม กดไลก์ แล้วให้โอนเงินสำรองเพื่อปลดล็อกระบบ');
      expect(job.categoriesHit.contains('job'), isTrue);
      expect(job.score, greaterThanOrEqualTo(18));

      final crypto = scanMessage('ลงทุนคริปโตกำไรการันตี ต้องโอนเพิ่มก่อนถอน');
      expect(crypto.categoriesHit.contains('crypto'), isTrue);
      expect(crypto.score, greaterThanOrEqualTo(18));
    });

    test('empty text scores 0', () {
      final r = scanMessage('   ');
      expect(r.score, 0);
      expect(r.hits, isEmpty);
    });
  });
}
