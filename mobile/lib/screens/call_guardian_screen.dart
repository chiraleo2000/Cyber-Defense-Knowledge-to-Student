import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme.dart';
import '../widgets/sos_bar.dart';

/// Phase 2 scaffold only — opt-in experimental, never auto hang-up.
class CallGuardianScreen extends StatefulWidget {
  const CallGuardianScreen({super.key});

  @override
  State<CallGuardianScreen> createState() => _CallGuardianScreenState();
}

class _CallGuardianScreenState extends State<CallGuardianScreen> {
  bool _optIn = false;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF6E0),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.warn),
          ),
          child: const Text(
            'ทดลอง / แนวคิด Phase 2 — ยังไม่ได้เชื่อมต่อสายโทรจริง และจะไม่ตัดสายอัตโนมัติเด็ดขาด',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 14),
        Text('ผู้พิทักษ์สาย', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 6),
        const Text(
          'แนวทางในอนาคต: กรองสายแปลกหน้า/VoIP → ถอดเสียงบนเครื่อง → '
          'คะแนน LEXICON สด → เตือนบนจอ + SOS 1441 → แนะนำให้วางสายเอง',
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          value: _optIn,
          onChanged: (v) => setState(() => _optIn = v),
          title: const Text('เปิดโหมดทดลอง (opt-in)'),
          subtitle: const Text('ไม่มีการดักฟังจริงในเวอร์ชันนี้ — เป็น UI โครงเท่านั้น'),
        ),
        if (_optIn) ...[
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('สถานะจำลอง', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  const Text('• กรองสาย: รอสายที่ไม่รู้จัก / VoIP (ยังไม่เชื่อม OS)'),
                  const Text('• STT: ใช้เฉพาะบนเครื่อง (ไม่อัปโหลดเสียง)'),
                  const Text('• คะแนนเสี่ยง: ใช้ LEXICON เดียวกับสแกนข้อความ'),
                  const Text('• การตัดสาย: ผู้ใช้กดเองเท่านั้น — แอปไม่ตัดอัตโนมัติ'),
                  const SizedBox(height: 12),
                  const Text('ข้อจำกัดระบบปฏิบัติการ'),
                  const SizedBox(height: 6),
                  Text(
                    'Android: Call Screening / Accessibility มีข้อจำกัดสิทธิ์และนโยบายสโตร์\n'
                    'iOS: CallKit ไม่ให้อ่านเสียงสายโทรแบบเรียลไทม์โดยทั่วไป — '
                    'ต้องออกแบบให้เคารพความเป็นส่วนตัวและไม่สัญญาเกินความเป็นไปได้',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  const SosBar(),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () => context.go('/help'),
                    child: const Text('แนะนำ: วางสายเอง แล้วโทร 1441'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
