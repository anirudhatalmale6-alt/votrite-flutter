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
    {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
    {'code': 'es', 'name': 'Español', 'flag': '🇪🇸'},
    {'code': 'zh-CN', 'name': '中文', 'flag': '🇨🇳'},
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
            colors: [Color(0xFFF8F9FA), Color(0xFFE8EAF6)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              Image.asset(
                'assets/images/votrite_logo.png',
                width: 80,
                height: 80,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.how_to_vote,
                  size: 64,
                  color: VotRiteTheme.darkBlue,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/thamb.png',
                    width: 32,
                    height: 32,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.translate,
                      size: 28,
                      color: VotRiteTheme.primaryBlue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Choose Language',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: VotRiteTheme.darkBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Select your preferred language',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      for (int i = 0; i < _languages.length; i++) ...[
                        _buildLanguageOption(
                          index: i + 1,
                          code: _languages[i]['code']!,
                          name: _languages[i]['name']!,
                          flag: _languages[i]['flag']!,
                        ),
                        if (i < _languages.length - 1) const SizedBox(height: 16),
                      ],
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Text(
                  'Voterite Inc.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[400],
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
    required int index,
    required String code,
    required String name,
    required String flag,
  }) {
    final isSelected = _selectedLang == code;
    return GestureDetector(
      onTap: () => _selectLanguage(code),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: isSelected
              ? VotRiteTheme.primaryBlue.withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? VotRiteTheme.primaryBlue : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? VotRiteTheme.primaryBlue.withOpacity(0.15)
                  : Colors.black.withOpacity(0.04),
              blurRadius: isSelected ? 12 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? VotRiteTheme.primaryBlue
                    : Colors.grey[100],
              ),
              child: Center(
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                    : Text(
                        '$index',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              flag,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(width: 16),
            Text(
              name,
              style: TextStyle(
                fontSize: 20,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? VotRiteTheme.primaryBlue
                    : VotRiteTheme.darkGray,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: isSelected ? VotRiteTheme.primaryBlue : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}
