import 'package:flutter/material.dart';

import '../core/checklists.dart';
import '../widgets/checklist_panel.dart';

class InvestScreen extends StatelessWidget {
  const InvestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ChecklistScreenBody(
      title: 'หลอกลงทุน',
      subtitle:
          'ตรวจสัญญาณการันตีกำไรสูง / แพลตฟอร์มไม่ได้รับอนุญาต / กดดันให้โอนเพิ่ม',
      items: kInvestItems,
    );
  }
}
