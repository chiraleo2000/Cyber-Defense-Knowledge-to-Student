import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../core/lexicon.dart';
import '../core/theme.dart';
import '../widgets/risk_gauge.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final _controller = TextEditingController();
  ScanResult? _result;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _run() {
    setState(() => _result = scanMessage(_controller.text));
  }

  void _clear() {
    _controller.clear();
    setState(() => _result = null);
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      _controller.text = data!.text!;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        Text('สแกนข้อความ', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 6),
        const Text(
          'วางข้อความแชท/SMS ที่ได้รับ ระบบจะไฮไลต์คำเสี่ยงและให้คะแนน '
          '(ประมวลผลบนเครื่อง ไม่ส่งข้อความออก)',
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _controller,
          maxLines: 8,
          decoration: const InputDecoration(
            hintText: 'วางข้อความที่นี่…',
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: FilledButton(onPressed: _run, child: const Text('สแกน')),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(onPressed: _paste, child: const Text('วางจากคลิปบอร์ด')),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(onPressed: _clear, child: const Text('ล้าง')),
            ),
          ],
        ),
        if (_result != null) ...[
          const SizedBox(height: 16),
          RiskResultCard(score: _result!.score, title: 'ผลการสแกน'),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: _HighlightedText(
                raw: _controller.text,
                hits: _result!.hits,
              ),
            ),
          ),
          if (_result!.hits.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'ไม่พบคำเข้าข่ายที่รู้จักในข้อความนี้ — แต่การไม่พบคำเข้าข่ายไม่ได้แปลว่าปลอดภัย 100%',
                style: TextStyle(color: AppTheme.inkFaint),
              ),
            ),
          if (_result!.score >= 60) ...[
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => context.go('/help'),
              style: FilledButton.styleFrom(backgroundColor: AppTheme.danger),
              child: const Text('เสี่ยงสูง — ไปขอความช่วยเหลือ / โทร 1441'),
            ),
          ],
        ],
      ],
    );
  }
}

class _HighlightedText extends StatelessWidget {
  const _HighlightedText({required this.raw, required this.hits});

  final String raw;
  final List<ScanHit> hits;

  Color _colorFor(String key) {
    switch (key) {
      case 'authority':
        return const Color(0xFF2B6CB0);
      case 'threat':
        return const Color(0xFFC53030);
      case 'control':
        return const Color(0xFF805AD5);
      case 'money':
        return const Color(0xFFB7791F);
      case 'handoff':
        return const Color(0xFFDD6B20);
      default:
        return AppTheme.accent;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (hits.isEmpty) {
      return Text(raw, style: const TextStyle(height: 1.5));
    }
    final spans = <TextSpan>[];
    var pos = 0;
    for (final h in hits) {
      if (h.start > pos) {
        spans.add(TextSpan(text: raw.substring(pos, h.start)));
      }
      spans.add(TextSpan(
        text: raw.substring(h.start, h.end),
        style: TextStyle(
          backgroundColor: _colorFor(h.categoryKey).withOpacity(0.18),
          color: _colorFor(h.categoryKey),
          fontWeight: FontWeight.w700,
        ),
      ));
      pos = h.end;
    }
    if (pos < raw.length) {
      spans.add(TextSpan(text: raw.substring(pos)));
    }
    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style.copyWith(height: 1.5),
        children: spans,
      ),
    );
  }
}
