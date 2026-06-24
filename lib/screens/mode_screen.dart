import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/voting_provider.dart';
import '../services/tts_service.dart';
import '../theme.dart';
import 'login_screen.dart';

class ModeScreen extends StatelessWidget {
  const ModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Mode')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Icon(Icons.how_to_vote, size: 48, color: VotRiteTheme.primaryBlue),
              const SizedBox(height: 16),
              const Text(
                'How would you like to vote?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: VotRiteTheme.darkBlue,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 64,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.touch_app, size: 28),
                  label: const Text('Normal Mode', style: TextStyle(fontSize: 18)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 64,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.accessibility_new, size: 28),
                  label: const Text('Visually Impaired', style: TextStyle(fontSize: 18)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: VotRiteTheme.primaryBlue, width: 2),
                    foregroundColor: VotRiteTheme.primaryBlue,
                  ),
                  onPressed: () {
                    context.read<VotingProvider>().setAccessibilityMode(true);
                    TtsService().setEnabled(true);
                    TtsService().speak(
                      'Visually impaired mode activated. Voice guidance enabled.',
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(accessibilityMode: true),
                      ),
                    );
                  },
                ),
              ),
              const Spacer(),
              TextButton.icon(
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back', style: TextStyle(fontSize: 16)),
                onPressed: () => Navigator.maybePop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
