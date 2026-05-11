import 'package:flutter_tts/flutter_tts.dart';

class SpeechService {
  final FlutterTts tts = FlutterTts();
  bool importantSpeechActive = false;

  Future<void> init() async {
    await tts.setLanguage("en-US");
    await tts.setSpeechRate(0.9);
    await tts.setPitch(1.0);
    await tts.awaitSpeakCompletion(true);
    tts.setCompletionHandler(() {
      importantSpeechActive = false;
    });
    tts.setCancelHandler(() {
      importantSpeechActive = false;
    });
    tts.setErrorHandler((msg) {
      importantSpeechActive = false;
    });
    await tts.setAudioAttributesForNavigation();
    await tts.setSharedInstance(true);
    await tts.setQueueMode(1);
  }

  Future<void> speakImportant(String text) async {
    importantSpeechActive = true;
    await tts.stop();
    await tts.speak(text);
  }

  Future<void> speak(String text, {bool interrupt = false}) async {
    if (importantSpeechActive) {
      return;
    }
    if (text.trim().isEmpty) {
      return;
    }
    if (interrupt) {
      await tts.stop();
    }
    await tts.speak(text);
  }

  Future<void> stop() async {
    await tts.stop();
  }
}
