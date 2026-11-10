import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/lexicon.dart';
import '../core/theme.dart';
import '../services/stt_service.dart';
import '../widgets/risk_gauge.dart';

class VoiceScreen extends StatefulWidget {
  const VoiceScreen({super.key});

  @override
  State<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends State<VoiceScreen> {
  final _stt = SttService();
  final _controller = TextEditingController();
  ScanResult? _result;
  String _status = 'ใช้ไมโครโฟนของระบบ (บนเครื่อง) เพื่อถอดเสียงภาษาไทย แล้วสแกนด้วย LEXICON เดียวกับหน้าสแกนข้อความ';
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _initStt();
  }

  Future<void> _initStt() async {
    final ok = await _stt.init();
    setState(() {
      _ready = ok;
      if (!ok) {
        _status =
            'อุปกรณ์นี้ยังไม่รองรับ Speech-to-Text ของระบบ — พิมพ์ข้อความที่ได้ยินแล้วกดสแกนแทน';
      }
    });
  }

  Future<void> _toggleMic() async {
    if (_stt.listening) {
      await _stt.stop();
      setState(() {});
      return;
    }
    final base = _controller.text.trim().isEmpty ? '' : '${_controller.text.trim()} ';
    await _stt.start(
      onResult: (text, isFinal) {
        setState(() {
          _controller.text = '$base$text'.trim();
          _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
        });
      },
    );
    setState(() {});
  }

  void _scan() {
    setState(() => _result = scanMessage(_controller.text));
  }

  void _clear() {
    _controller.clear();
    setState(() => _result = null);
  }

  @override
  void dispose() {
    _stt.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        Text('ถอดเสียงสนทนา', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 6),
        Text(_status),
        const SizedBox(height: 12),
        if (_ready)
          FilledButton.icon(
            onPressed: _toggleMic,
            icon: Icon(_stt.listening ? Icons.stop : Icons.mic),
            label: Text(_stt.listening ? 'กำลังฟัง… (แตะเพื่อหยุด)' : 'เริ่มถอดเสียงพูดอัตโนมัติ'),
            style: FilledButton.styleFrom(
              backgroundColor: _stt.listening ? AppTheme.danger : AppTheme.accent,
            ),
          ),
        const SizedBox(height: 12),
        TextField(
          controller: _controller,
          maxLines: 8,
          decoration: const InputDecoration(
            hintText: 'ข้อความถอดเสียงหรือพิมพ์เอง…',
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: FilledButton(onPressed: _scan, child: const Text('สแกนข้อความ')),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(onPressed: _clear, child: const Text('ล้าง')),
            ),
          ],
        ),
        if (_result != null) ...[
          const SizedBox(height: 16),
          RiskResultCard(score: _result!.score, title: 'ผลการสแกนจากเสียง/ข้อความ'),
          if (_result!.score >= 60) ...[
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => context.go('/help'),
              style: FilledButton.styleFrom(backgroundColor: AppTheme.danger),
              child: const Text('เสี่ยงสูง — โทร 1441'),
            ),
          ],
        ],
      ],
    );
  }
}
