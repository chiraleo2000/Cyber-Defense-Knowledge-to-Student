import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/agent_offline.dart';

const _prefsKey = 'cko-agent-url';

/// Optional Pathumma worker chat — mirrors webapp agent URL prefs.
///
/// CORS note: Cloudflare Worker must allow the app origin (or `*`) for
/// browser clients; native Flutter HTTP is not subject to browser CORS,
/// but the worker should still authenticate / rate-limit as documented
/// in `worker/README.md`.
class AgentService {
  AgentService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  String? _workerUrl;
  bool online = false;
  bool checked = false;

  String? get workerUrl => _workerUrl;

  Future<void> loadSavedUrl() async {
    final prefs = await SharedPreferences.getInstance();
    _workerUrl = prefs.getString(_prefsKey);
  }

  Future<void> setWorkerUrl(String? url) async {
    final prefs = await SharedPreferences.getInstance();
    final trimmed = url?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      await prefs.remove(_prefsKey);
      _workerUrl = null;
      online = false;
      checked = false;
      return;
    }
    await prefs.setString(_prefsKey, trimmed);
    _workerUrl = trimmed;
    online = false;
    checked = false;
  }

  Future<String> statusMessage() async {
    if (checked) {
      if (_workerUrl == null || _workerUrl!.isEmpty) {
        return 'ยังไม่ได้ตั้งค่าผู้ช่วย AI ออนไลน์ — ระบบจะตอบด้วยคำแนะนำพื้นฐานแบบออฟไลน์แทน';
      }
      return online
          ? 'เชื่อมต่อผู้ช่วย AI (Pathumma) สำเร็จ — พร้อมตอบคำถาม'
          : 'ผู้ช่วย AI ออนไลน์ยังไม่พร้อม — ใช้โหมดออฟไลน์แทน';
    }
    checked = true;
    if (_workerUrl == null || _workerUrl!.isEmpty) {
      return 'ยังไม่ได้ตั้งค่าผู้ช่วย AI ออนไลน์ — ระบบจะตอบด้วยคำแนะนำพื้นฐานแบบออฟไลน์แทน '
          '(ดู worker/README.md)';
    }
    try {
      final res = await _client.post(
        Uri.parse(_workerUrl!),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'messages': [
            {'role': 'user', 'content': 'ping'}
          ]
        }),
      );
      final data = jsonDecode(res.body);
      if (res.statusCode >= 200 &&
          res.statusCode < 300 &&
          data is Map &&
          data['reply'] != null) {
        online = true;
        return 'เชื่อมต่อผู้ช่วย AI (Pathumma) สำเร็จ — พร้อมตอบคำถาม';
      }
      online = false;
      final err = data is Map ? data['error'] : null;
      return 'ผู้ช่วย AI ออนไลน์ยังไม่พร้อมใช้งาน (${err ?? 'ไม่ทราบสาเหตุ'}) — ใช้โหมดออฟไลน์แทน';
    } catch (_) {
      online = false;
      return 'ไม่สามารถเชื่อมต่อผู้ช่วย AI ออนไลน์ได้ — ใช้โหมดออฟไลน์แทน';
    }
  }

  Future<String> reply({
    required String userText,
    required List<Map<String, String>> history,
  }) async {
    if (_workerUrl != null && _workerUrl!.isNotEmpty && online) {
      try {
        final res = await _client.post(
          Uri.parse(_workerUrl!),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'messages': history}),
        );
        final data = jsonDecode(res.body);
        if (res.statusCode >= 200 &&
            res.statusCode < 300 &&
            data is Map &&
            data['reply'] is String) {
          return data['reply'] as String;
        }
      } catch (_) {
        // fall through to offline
      }
    }
    return agentOfflineReply(userText);
  }
}
