import 'package:check_before_transfer/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('home shows Thai brand and disclaimer', (tester) async {
    await tester.pumpWidget(const CheckBeforeTransferApp());
    await tester.pumpAndSettle();

    expect(find.textContaining('เช็คก่อนโอน'), findsWidgets);
    expect(find.textContaining('1441'), findsWidgets);
  });
}
