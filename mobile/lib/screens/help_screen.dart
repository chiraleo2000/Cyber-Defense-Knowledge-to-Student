import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../widgets/sos_bar.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const steps = [
      ('01', 'วางสายทันที', 'ไม่ต้องกลัวผิดมารยาทหรือผิดกฎหมาย หน่วยงานจริงจะไม่ตำหนิที่คุณตรวจสอบก่อน'),
      ('02', 'ปรึกษาคนใกล้ตัวก่อนเสมอ', 'บอกพ่อแม่ เพื่อนร่วมห้อง หรืออาจารย์ที่ปรึกษา — คนร้ายกลัวที่สุดคือการถูกเปิดเผย'),
      ('03', 'ตรวจสอบผ่านช่องทางทางการเท่านั้น', 'โทรกลับเบอร์คอลเซ็นเตอร์ทางการของหน่วยงานเอง ไม่ใช่เบอร์หรือแอปที่ฝ่ายตรงข้ามส่งมาให้'),
      ('04', 'ห้ามโอนเงินหรือถอนเงินสดเด็ดขาด', 'จนกว่าจะตรวจสอบข้อเท็จจริงได้ครบถ้วนกับหน่วยงานหรือธนาคารโดยตรง'),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        Text('ขอความช่วยเหลือ', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 6),
        const Text(
          'ไม่ว่าผลประเมินจะออกมาระดับใด ขั้นตอนต่อไปนี้ปลอดภัยที่สุดเสมอเมื่อรู้สึกไม่มั่นใจ',
        ),
        const SizedBox(height: 12),
        Card(
          color: const Color(0xFFFFF5F5),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Text(
              'ข้อควรระวังเป็นพิเศษ: ห้ามไปถอนเงินสดหรือส่งมอบเงินให้คนแปลกหน้าตามลำพัง '
              'โดยเฉพาะเวลากลางคืน',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.danger,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        for (final s in steps)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.accent,
                  foregroundColor: Colors.white,
                  radius: 18,
                  child: Text(s.$1, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.$2, style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(s.$3),
                    ],
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        const HotlineGrid(),
        const SizedBox(height: 8),
        Text(
          'หากมีการโอนเงินไปแล้ว ให้ติดต่อธนาคารเพื่อขออายัดบัญชีทันที '
          'พร้อมแจ้งความหรือโทร 1441 ควบคู่กัน ยิ่งแจ้งเร็ว โอกาสอายัดเงินคืนยิ่งสูง',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
