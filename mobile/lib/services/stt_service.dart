import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Native OS speech-to-text (Thai preferred) — privacy-first over cloud Whisper.
class SttService {
  SttService({stt.SpeechToText? speech}) : _speech = speech ?? stt.SpeechToText();

  final stt.SpeechToText _speech;
  bool available = false;
  bool listening = false;

  Future<bool> init() async {
    available = await _speech.initialize(
      onError: (_) {
        listening = false;
      },
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          listening = false;
        }
      },
    );
    return available;
  }

  Future<void> start({
    required void Function(String text, bool isFinal) onResult,
    String localeId = 'th_TH',
  }) async {
    if (!available) {
      final ok = await init();
      if (!ok) return;
    }
    listening = true;
    await _speech.listen(
      onResult: (result) {
        onResult(result.recognizedWords, result.finalResult);
      },
      localeId: localeId,
      listenMode: stt.ListenMode.dictation,
      partialResults: true,
      cancelOnError: true,
    );
  }

  Future<void> stop() async {
    listening = false;
    await _speech.stop();
  }

  Future<void> cancel() async {
    listening = false;
    await _speech.cancel();
  }
}
