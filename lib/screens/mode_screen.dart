import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/voting_provider.dart';
import '../services/tts_service.dart';
import '../theme.dart';
import 'login_screen.dart';

class ModeScreen extends StatefulWidget {
  const ModeScreen({super.key});

  @override
  State<ModeScreen> createState() => _ModeScreenState();
}

class _ModeScreenState extends State<ModeScreen> {
  final _focusNode = FocusNode();
  int _selectedMode = -1; // 0=normal, 1=visually impaired

  void _proceed() {
    final provider = context.read<VotingProvider>();
    final tts = TtsService();

    if (_selectedMode == 1) {
      provider.setAccessibilityMode(true);
      tts.setEnabled(true);
      tts.speak('Visually impaired mode activated. Proceeding to PIN entry.');
    } else {
      provider.setAccessibilityMode(false);
      tts.setEnabled(false);
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  void _testSpeech() {
    TtsService().speakAlways(
      'This is a test of the text-to-speech system. '
      'If you can hear this, your device supports voice assistance. '
      'When ready, press J key to continue, or tap Next.',
    );
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.keyF) {
      if (_selectedMode < 0) {
        setState(() => _selectedMode = 0);
        TtsService().speakAlways('Normal mode selected. Press F again to switch, J to continue.');
      } else {
        setState(() => _selectedMode = _selectedMode == 0 ? 1 : 0);
        final mode = _selectedMode == 0 ? 'Normal' : 'Visually Impaired';
        TtsService().speakAlways('$mode mode selected. Press J to continue.');
      }
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.keyJ || key == LogicalKeyboardKey.enter) {
      if (_selectedMode >= 0) {
        _proceed();
      } else {
        TtsService().speakAlways('Please select a mode first. Press F to select.');
      }
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.keyD || key == LogicalKeyboardKey.escape) {
      Navigator.maybePop(context);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.keyS) {
      final mode = _selectedMode < 0
          ? 'No mode selected'
          : _selectedMode == 0
              ? 'Normal mode'
              : 'Visually Impaired mode';
      TtsService().speakAlways('$mode currently selected.');
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.keyL) {
      TtsService().speakAlways(
        'Mode selection screen. F to toggle between Normal and Visually Impaired mode. '
        'J or Enter to continue. D to go back. S to hear current selection.',
      );
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKey,
      child: Scaffold(
        appBar: AppBar(title: const Text('Select Mode')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Text(
                'How would you like to vote?',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _ModeCard(
                icon: Icons.touch_app,
                title: 'Normal Mode',
                description: 'Use touch screen to navigate and vote',
                isSelected: _selectedMode == 0,
                onTap: () {
                  setState(() => _selectedMode = 0);
                  TtsService().speakAlways('Normal mode selected.');
                },
              ),
              const SizedBox(height: 16),
              _ModeCard(
                icon: Icons.accessibility_new,
                title: 'Visually Impaired Mode',
                description: 'Voice guidance with keyboard navigation',
                isSelected: _selectedMode == 1,
                onTap: () {
                  setState(() => _selectedMode = 1);
                  TtsService().speakAlways('Visually Impaired mode selected. Voice guidance will be enabled.');
                },
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: _testSpeech,
                icon: const Icon(Icons.volume_up),
                label: const Text('Test Speech'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.maybePop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Back', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _selectedMode >= 0 ? _proceed : null,
                      child: const Text('Next'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$title. $description',
      selected: isSelected,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isSelected ? VotRiteTheme.primaryBlue.withValues(alpha: 0.1) : VotRiteTheme.lightGray,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? VotRiteTheme.primaryBlue : Colors.grey.shade300,
              width: isSelected ? 3 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 48,
                color: isSelected ? VotRiteTheme.primaryBlue : VotRiteTheme.darkGray,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? VotRiteTheme.primaryBlue : VotRiteTheme.darkGray,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(description, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle, color: VotRiteTheme.primaryBlue, size: 32),
            ],
          ),
        ),
      ),
    );
  }
}
