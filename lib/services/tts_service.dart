import 'dart:io' show Platform;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;
  bool _enabled = false;
  bool _speaking = false;

  bool get enabled => _enabled;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    try {
      if (Platform.isIOS) {
        await _tts.setSharedInstance(true);
        await _tts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.ambient,
          [IosTextToSpeechAudioCategoryOptions.defaultToSpeaker],
          IosTextToSpeechAudioMode.voicePrompt,
        );
      }

      await _tts.setLanguage('en-US');
      await _tts.awaitSpeakCompletion(false);

      _tts.setCompletionHandler(() => _speaking = false);
      _tts.setCancelHandler(() => _speaking = false);
      _tts.setErrorHandler((_) => _speaking = false);

      final prefs = await SharedPreferences.getInstance();
      final rate = prefs.getDouble('tts_rate') ?? 0.5;
      await _tts.setSpeechRate(rate);
      _enabled = prefs.getBool('accessibility_mode') ?? false;
    } catch (_) {
      _initialized = false;
    }
  }

  Future<void> _ensureInit() async {
    if (!_initialized) await init();
  }

  Future<void> setEnabled(bool value) async {
    _enabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('accessibility_mode', value);
  }

  Future<void> setSpeechRate(double rate) async {
    await _ensureInit();
    try {
      await _tts.setSpeechRate(rate);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('tts_rate', rate);
    } catch (_) {}
  }

  Future<void> speak(String text) async {
    if (!_enabled) return;
    await _ensureInit();
    try {
      if (_speaking) await _tts.stop();
      _speaking = true;
      await _tts.speak(text);
    } catch (_) {
      _speaking = false;
    }
  }

  Future<void> speakAlways(String text) async {
    await _ensureInit();
    try {
      if (_speaking) await _tts.stop();
      _speaking = true;
      await _tts.speak(text);
    } catch (_) {
      _speaking = false;
    }
  }

  Future<void> stop() async {
    try {
      _speaking = false;
      await _tts.stop();
    } catch (_) {}
  }
}
