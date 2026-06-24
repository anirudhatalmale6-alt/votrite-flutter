import 'package:flutter/material.dart';
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
  int _selectedMode = -1;

  void _proceed() {
    final provider = context.read<VotingProvider>();

    if (_selectedMode == 1) {
      provider.setAccessibilityMode(true);
      TtsService().setEnabled(true);
      TtsService().speak('Visually impaired mode activated. Proceeding to PIN entry.');
    } else {
      provider.setAccessibilityMode(false);
      TtsService().setEnabled(false);
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            GestureDetector(
              onTap: () => setState(() => _selectedMode = 0),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _selectedMode == 0
                      ? const Color(0xFFE3F2FD)
                      : VotRiteTheme.lightGray,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedMode == 0
                        ? VotRiteTheme.primaryBlue
                        : Colors.grey.shade300,
                    width: _selectedMode == 0 ? 3 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.touch_app,
                      size: 48,
                      color: _selectedMode == 0
                          ? VotRiteTheme.primaryBlue
                          : VotRiteTheme.darkGray,
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Normal Mode',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: _selectedMode == 0
                                  ? VotRiteTheme.primaryBlue
                                  : VotRiteTheme.darkGray,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Use touch screen to navigate and vote',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    if (_selectedMode == 0)
                      const Icon(Icons.check_circle,
                          color: VotRiteTheme.primaryBlue, size: 32),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                setState(() => _selectedMode = 1);
                TtsService().speakAlways(
                    'Visually Impaired mode selected. Voice guidance will be enabled.');
              },
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _selectedMode == 1
                      ? const Color(0xFFE3F2FD)
                      : VotRiteTheme.lightGray,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedMode == 1
                        ? VotRiteTheme.primaryBlue
                        : Colors.grey.shade300,
                    width: _selectedMode == 1 ? 3 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.accessibility_new,
                      size: 48,
                      color: _selectedMode == 1
                          ? VotRiteTheme.primaryBlue
                          : VotRiteTheme.darkGray,
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Visually Impaired Mode',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: _selectedMode == 1
                                  ? VotRiteTheme.primaryBlue
                                  : VotRiteTheme.darkGray,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Voice guidance with keyboard navigation',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    if (_selectedMode == 1)
                      const Icon(Icons.check_circle,
                          color: VotRiteTheme.primaryBlue, size: 32),
                  ],
                ),
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
    );
  }
}
