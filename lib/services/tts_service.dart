import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;
  bool _initInProgress = false;
  bool _enabled = false;
  bool _speaking = false;

  bool get enabled => _enabled;

  Future<void> init() async {
    if (_initialized || _initInProgress) return;
    _initInProgress = true;

    try {
      if (Platform.isIOS) {
        await _tts.setSharedInstance(true).timeout(const Duration(seconds: 3), onTimeout: () {});
        await _tts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playback,
          [IosTextToSpeechAudioCategoryOptions.defaultToSpeaker],
          IosTextToSpeechAudioMode.voicePrompt,
        ).timeout(const Duration(seconds: 3), onTimeout: () {});
      }

      await _tts.setLanguage('en-US');
      await _tts.awaitSpeakCompletion(false);
      await _tts.setVolume(1.0);

      _tts.setCompletionHandler(() => _speaking = false);
      _tts.setCancelHandler(() => _speaking = false);
      _tts.setErrorHandler((_) => _speaking = false);

      final prefs = await SharedPreferences.getInstance();
      final rate = prefs.getDouble('tts_rate') ?? 0.45;
      await _tts.setSpeechRate(rate);
      _enabled = prefs.getBool('accessibility_mode') ?? false;
      _initialized = true;
    } catch (_) {}
    _initInProgress = false;
  }

  Future<void> _ensureInit() async {
    if (!_initialized && !_initInProgress) {
      await init().timeout(const Duration(seconds: 5), onTimeout: () {});
    }
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
      if (_speaking) await _tts.stop().timeout(const Duration(seconds: 1), onTimeout: () {});
      _speaking = true;
      await _tts.speak(text).timeout(const Duration(seconds: 3), onTimeout: () {});
    } catch (_) {
      _speaking = false;
    }
  }

  Future<void> speakAlways(String text) async {
    await _ensureInit();
    try {
      if (_speaking) await _tts.stop().timeout(const Duration(seconds: 1), onTimeout: () {});
      _speaking = true;
      await _tts.speak(text).timeout(const Duration(seconds: 3), onTimeout: () {});
    } catch (_) {
      _speaking = false;
    }
  }

  Future<void> stop() async {
    try {
      _speaking = false;
      await _tts.stop().timeout(const Duration(seconds: 1), onTimeout: () {});
    } catch (_) {}
  }
}
