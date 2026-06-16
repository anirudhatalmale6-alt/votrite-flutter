import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;
  bool _enabled = false;

  bool get enabled => _enabled;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    await _tts.setLanguage('en-US');
    final prefs = await SharedPreferences.getInstance();
    final rate = prefs.getDouble('tts_rate') ?? 0.5;
    await _tts.setSpeechRate(rate);
    _enabled = prefs.getBool('accessibility_mode') ?? false;
  }

  Future<void> setEnabled(bool value) async {
    _enabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('accessibility_mode', value);
  }

  Future<void> setSpeechRate(double rate) async {
    await _tts.setSpeechRate(rate);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('tts_rate', rate);
  }

  Future<void> speak(String text) async {
    if (!_enabled) return;
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> speakAlways(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
  }
}
