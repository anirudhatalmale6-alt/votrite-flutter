import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/voting_provider.dart';
import '../services/tts_service.dart';
import '../theme.dart';
import 'mode_screen.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String? _selectedLang;

  static const _languages = [
    {'code': 'en', 'name': 'English', 'native': 'English', 'flag': '🇺🇸'},
    {'code': 'es', 'name': 'Español', 'native': 'Spanish', 'flag': '🇪🇸'},
    {'code': 'zh-CN', 'name': '中文', 'native': 'Chinese', 'flag': '🇨🇳'},
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      TtsService().speakAlways('Choose your language. English. Español. Chinese.');
    });
  }

  void _selectLanguage(String code) {
    setState(() => _selectedLang = code);
    final name = _languages.firstWhere((l) => l['code'] == code)['name']!;
    TtsService().speakAlways('$name selected.');
    context.read<VotingProvider>().setLanguage(code);
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ModeScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A2463), Color(0xFF1565C0)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 32),
              Image.asset(
                'assets/images/votrite_logo.png',
                width: 64,
                height: 64,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.how_to_vote,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'VotRite',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.translate, size: 16, color: Colors.white70),
                    SizedBox(width: 8),
                    Text(
                      'Select Your Language',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    for (int i = 0; i < _languages.length; i++) ...[
                      _buildLanguageOption(
                        code: _languages[i]['code']!,
                        name: _languages[i]['name']!,
                        native: _languages[i]['native']!,
                        flag: _languages[i]['flag']!,
                      ),
                      if (i < _languages.length - 1) const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  'Voterite Inc.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOption({
    required String code,
    required String name,
    required String native,
    required String flag,
  }) {
    final isSelected = _selectedLang == code;
    return GestureDetector(
      onTap: () => _selectLanguage(code),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.25),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? VotRiteTheme.darkBlue : Colors.white,
                  ),
                ),
                Text(
                  native,
                  style: TextStyle(
                    fontSize: 11,
                    color: isSelected
                        ? VotRiteTheme.darkBlue.withOpacity(0.6)
                        : Colors.white60,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Icon(
              isSelected ? Icons.check_circle : Icons.arrow_forward_ios,
              size: 18,
              color: isSelected ? VotRiteTheme.primaryBlue : Colors.white54,
            ),
          ],
        ),
      ),
    );
  }
}
