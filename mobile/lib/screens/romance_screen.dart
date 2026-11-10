import 'package:flutter/material.dart';

import '../core/checklists.dart';
import '../widgets/checklist_panel.dart';

class RomanceScreen extends StatelessWidget {
  const RomanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ChecklistScreenBody(
      title: 'Romance Scam',
      subtitle:
          'เช็คสัญญาณหลอกลวงความรักออนไลน์ — โดยเฉพาะเมื่อถูกขอเงินหรือชวนลงทุน',
      items: kRomanceItems,
    );
  }
}
