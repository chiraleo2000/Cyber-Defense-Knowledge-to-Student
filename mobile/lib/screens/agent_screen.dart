import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../services/agent_service.dart';

class AgentScreen extends StatefulWidget {
  const AgentScreen({super.key});

  @override
  State<AgentScreen> createState() => _AgentScreenState();
}

class _AgentScreenState extends State<AgentScreen> {
  final _service = AgentService();
  final _input = TextEditingController();
  final _urlCtrl = TextEditingController();
  final _log = <_ChatBubble>[];
  final _history = <Map<String, String>>[];
  String _status = 'กำลังโหลด…';
  bool _sending = false;

  static const _suggestions = [
    'มีคนโทรมาอ้างเป็นตำรวจ บอกว่าฉันพัวพันคดีฟอกเงิน ต้องทำยังไง',
    'แฟนออนไลน์ที่ไม่เคยเจอตัวขอยืมเงินด่วน เชื่อได้ไหม',
    'มีคนชวนลงทุนบอกว่าได้กำไรแน่นอน 20% ต่อเดือน น่าเชื่อถือไหม',
  ];

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await _service.loadSavedUrl();
    _urlCtrl.text = _service.workerUrl ?? '';
    final status = await _service.statusMessage();
    if (mounted) setState(() => _status = status);
  }

  Future<void> _saveUrl() async {
    await _service.setWorkerUrl(_urlCtrl.text);
    final status = await _service.statusMessage();
    if (mounted) setState(() => _status = status);
  }

  Future<void> _send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _sending) return;
    setState(() {
      _sending = true;
      _log.add(_ChatBubble(role: 'user', text: trimmed));
      _history.add({'role': 'user', 'content': trimmed});
      _input.clear();
      _log.add(const _ChatBubble(role: 'assistant', text: 'กำลังพิมพ์…'));
    });
    final reply = await _service.reply(
      userText: trimmed,
      history: _history.length > 10 ? _history.sublist(_history.length - 10) : _history,
    );
    if (!mounted) return;
    setState(() {
      _log[_log.length - 1] = _ChatBubble(role: 'assistant', text: reply);
      _history.add({'role': 'assistant', 'content': reply});
      _sending = false;
    });
  }

  @override
  void dispose() {
    _input.dispose();
    _urlCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        Text('ผู้ช่วย AI', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 6),
        const Text(
          'พิมพ์อธิบายสถานการณ์ที่สงสัย — ไม่ใช่บริการฉุกเฉิน หากอันตรายให้โทร 1441/191',
        ),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(_status, style: Theme.of(context).textTheme.bodySmall),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _urlCtrl,
          decoration: const InputDecoration(
            labelText: 'Pathumma worker URL (ไม่บังคับ)',
            hintText: 'https://…workers.dev/chat',
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton(
            onPressed: _saveUrl,
            child: const Text('บันทึก URL / ตรวจสอบการเชื่อมต่อ'),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'ห้ามพิมพ์เลขบัตรประชาชน เลขบัญชี หรือ OTP ในแชทนี้',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.danger,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        for (final q in _suggestions)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: OutlinedButton(
              onPressed: () => _send(q),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(q, maxLines: 2, overflow: TextOverflow.ellipsis),
              ),
            ),
          ),
        const SizedBox(height: 8),
        for (final b in _log)
          Align(
            alignment: b.role == 'user' ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.85,
              ),
              decoration: BoxDecoration(
                color: b.role == 'user' ? AppTheme.accent : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: b.role == 'user' ? null : Border.all(color: AppTheme.line),
              ),
              child: Text(
                b.text,
                style: TextStyle(
                  color: b.role == 'user' ? Colors.white : AppTheme.ink,
                  height: 1.45,
                ),
              ),
            ),
          ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _input,
                minLines: 1,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'พิมพ์คำถามหรืออธิบายสถานการณ์…',
                ),
                onSubmitted: _send,
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: _sending ? null : () => _send(_input.text),
              child: const Text('ส่ง'),
            ),
          ],
        ),
      ],
    );
  }
}

class _ChatBubble {
  const _ChatBubble({required this.role, required this.text});
  final String role;
  final String text;
}
