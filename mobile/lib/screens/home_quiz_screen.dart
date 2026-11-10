import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/checklists.dart';
import '../core/hotlines.dart';
import '../core/theme.dart';
import '../widgets/checklist_panel.dart';
import '../widgets/risk_gauge.dart';
import '../widgets/sos_bar.dart';

class HomeQuizScreen extends StatefulWidget {
  const HomeQuizScreen({super.key});

  @override
  State<HomeQuizScreen> createState() => _HomeQuizScreenState();
}

class _HomeQuizScreenState extends State<HomeQuizScreen> {
  final _quizKey = GlobalKey<ChecklistPanelState>();
  int? _score;
  List<String> _suggestions = [];

  void _evaluate() {
    final state = _quizKey.currentState;
    if (state == null) return;
    final score = state.evaluate();
    final selected = state.selected;
    final goto = <String>{};
    for (var i = 0; i < selected.length; i++) {
      if (selected[i]) {
        goto.addAll(kQuizItems[i].gotoRoutes);
      }
    }
    setState(() {
      _score = score;
      _suggestions = goto.toList();
    });
  }

  void _reset() {
    _quizKey.currentState?.reset();
    setState(() {
      _score = null;
      _suggestions = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        Text('เช็คก่อนโอน', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 4),
        Text(
          'หยุดก่อนเงินออกจากบัญชี — ประเมินสถานการณ์แล้วเปิดเครื่องมือที่เหมาะ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.inkSoft,
              ),
        ),
        const SizedBox(height: 12),
        Card(
          color: const Color(0xFFF0F7FF),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kPrivacyBaseline,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 10),
                const SosBar(),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text('สถานการณ์ตอนนี้', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final tile in kTriageTiles)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppTheme.line),
              ),
              tileColor: Colors.white,
              leading: Icon(_iconFor(tile.icon), color: AppTheme.accent),
              title: Text(tile.label),
              subtitle: Text(tile.hint),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go('/${tile.route}'),
            ),
          ),
        const SizedBox(height: 18),
        Text('แบบประเมินด่วน', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 6),
        const Text('ตอบตามสถานการณ์จริง แล้วกดประเมินผล'),
        const SizedBox(height: 10),
        ChecklistPanel(
          key: _quizKey,
          items: kQuizItems,
          mode: ChecklistMode.yesNo,
        ),
        EvalActions(onEval: _evaluate, onReset: _reset),
        if (_score != null) ...[
          const SizedBox(height: 16),
          RiskResultCard(score: _score!),
          if (_suggestions.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('แนะนำเครื่องมือต่อ', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final key in _suggestions)
                  OutlinedButton(
                    onPressed: () => context.go('/$key'),
                    child: Text(kPageLabels[key] ?? key),
                  ),
              ],
            ),
          ],
          if (_score! >= 60) ...[
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => context.go('/help'),
              icon: const Icon(Icons.emergency),
              label: const Text('ไปหน้าขอความช่วยเหลือ / โทร 1441'),
              style: FilledButton.styleFrom(backgroundColor: AppTheme.danger),
            ),
          ],
        ],
        const SizedBox(height: 24),
        TextButton(
          onPressed: () => context.go('/guardian'),
          child: const Text('ผู้พิทักษ์สาย (ทดลอง Phase 2) — ไม่ตัดสายอัตโนมัติ'),
        ),
      ],
    );
  }

  IconData _iconFor(String key) {
    switch (key) {
      case 'video':
        return Icons.videocam_outlined;
      case 'doc':
        return Icons.description_outlined;
      case 'mic':
        return Icons.mic_none;
      case 'heart':
        return Icons.favorite_border;
      case 'chart':
        return Icons.show_chart;
      case 'help':
        return Icons.support_agent;
      default:
        return Icons.chat_bubble_outline;
    }
  }
}
