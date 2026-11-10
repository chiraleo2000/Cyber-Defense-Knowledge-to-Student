import 'package:check_before_transfer/core/agent_offline.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('offline reply catches Telegram / OTP pattern', () {
    final reply = agentOfflineReply('ถูกชวนเข้า Telegram ห้องสอบสวน และขอรหัส LINE');
    expect(reply.contains('1441'), isTrue);
    expect(reply.contains('ออฟไลน์'), isTrue);
  });

  test('offline reply catches invest pressure', () {
    final reply = agentOfflineReply('ชวนลงทุนคริปโตกำไรการันตี');
    expect(reply.contains('ก.ล.ต.'), isTrue);
    expect(reply.contains('ปลดล็อก'), isTrue);
  });

  test('offline reply catches job scam and tells user not to transfer', () {
    final reply = agentOfflineReply('ชวนงานเสริมกดไลก์ ต้องโอนเงินสำรองเปิดระบบ');
    expect(reply.contains('1441'), isTrue);
    expect(reply.contains('โอนก่อน'), isTrue);
  });
}
