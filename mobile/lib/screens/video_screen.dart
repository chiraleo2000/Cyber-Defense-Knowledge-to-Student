import 'package:flutter/material.dart';

import '../core/checklists.dart';
import '../widgets/checklist_panel.dart';

class VideoScreen extends StatelessWidget {
  const VideoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ChecklistScreenBody(
      title: 'ตรวจสอบวิดีโอคอล',
      subtitle:
          'สังเกตสัญญาณวิดีโอคอลปลอมที่พบบ่อย แล้วประเมินความเสี่ยงก่อนโอนหรือให้ข้อมูล',
      items: kVideoItems,
    );
  }
}
