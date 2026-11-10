import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/checklists.dart';
import '../core/exif.dart';
import '../core/theme.dart';
import '../widgets/checklist_panel.dart';
import '../widgets/risk_gauge.dart';

class ImageScreen extends StatefulWidget {
  const ImageScreen({super.key});

  @override
  State<ImageScreen> createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  final _picker = ImagePicker();
  final _chkKey = GlobalKey<ChecklistPanelState>();
  Uint8List? _bytes;
  ExifSummary? _exif;
  int? _score;

  Future<void> _pick() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    final exif = parseJpegExif(bytes);
    setState(() {
      _bytes = bytes;
      _exif = exif;
      _score = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        Text('ตรวจสอบภาพ/เอกสาร', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 6),
        const Text(
          'เลือกภาพหน้าจอหรือเอกสารที่ได้รับ ระบบอ่าน EXIF บนเครื่อง '
          '(ไม่ได้อัปโหลดออก) และให้ประเมินตามเกณฑ์เอกสารปลอม',
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _pick,
          icon: const Icon(Icons.photo_library_outlined),
          label: const Text('เลือกภาพจากเครื่อง'),
        ),
        if (_bytes != null) ...[
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(_bytes!, height: 200, fit: BoxFit.contain),
          ),
          const SizedBox(height: 12),
          _ExifBox(summary: _exif ?? const ExifSummary(parseFailed: true)),
        ],
        const SizedBox(height: 16),
        ChecklistPanel(key: _chkKey, items: kImageItems),
        EvalActions(
          onEval: () {
            final score = _chkKey.currentState?.evaluate() ?? 0;
            setState(() => _score = score);
          },
          onReset: () {
            _chkKey.currentState?.reset();
            setState(() {
              _score = null;
              _bytes = null;
              _exif = null;
            });
          },
        ),
        if (_score != null) ...[
          const SizedBox(height: 16),
          RiskResultCard(score: _score!),
        ],
      ],
    );
  }
}

class _ExifBox extends StatelessWidget {
  const _ExifBox({required this.summary});

  final ExifSummary summary;

  @override
  Widget build(BuildContext context) {
    final flagged = summary.hasEditSoftwareHint;
    final rows = <Widget>[];
    if (summary.software != null && summary.software!.isNotEmpty) {
      rows.add(_row(
        'โปรแกรมที่ใช้แก้ไข',
        '${summary.software}${flagged ? ' ⚠️' : ''}',
      ));
    }
    if ((summary.make != null && summary.make!.isNotEmpty) ||
        (summary.model != null && summary.model!.isNotEmpty)) {
      rows.add(_row(
        'กล้อง/อุปกรณ์',
        [summary.make, summary.model].whereType<String>().where((s) => s.isNotEmpty).join(' '),
      ));
    }
    if (rows.isEmpty) {
      rows.add(_row(
        'ข้อมูล EXIF',
        summary.isJpeg
            ? 'ไม่พบข้อมูล (ปกติสำหรับภาพแคปหน้าจอ/PNG หรือไฟล์ที่ถูกลบข้อมูลออก)'
            : 'ไม่ใช่ JPEG หรืออ่านข้อมูลไม่ได้',
      ));
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: flagged ? const Color(0xFFFFF6E0) : AppTheme.surface2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: flagged ? AppTheme.warn : AppTheme.line,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...rows,
          const SizedBox(height: 8),
          Text(
            'ข้อมูลนี้เป็นเพียงเบาะแสประกอบ ไม่ใช่การยืนยันขั้นสุดท้าย '
            'เนื่องจากสามารถถูกลบหรือปลอมแปลงได้',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.inkFaint,
                ),
          ),
        ],
      ),
    );
  }

  Widget _row(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(child: Text(k, style: const TextStyle(color: AppTheme.inkFaint))),
          Expanded(child: Text(v, textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}
