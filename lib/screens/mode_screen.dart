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
    if (_selectedMode == 1) {
      context.read<VotingProvider>().setAccessibilityMode(true);
      TtsService().setEnabled(true);
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen(accessibilityMode: _selectedMode == 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ballotName = context.read<VotingProvider>().selectedBallot?.election ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Select Mode')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.how_to_vote, size: 32, color: VotRiteTheme.darkBlue),
                const SizedBox(width: 12),
                const Text(
                  'How would you like to vote?',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: VotRiteTheme.darkBlue),
                ),
              ],
            ),
            if (ballotName.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(ballotName, style: const TextStyle(fontSize: 14, color: Colors.grey), textAlign: TextAlign.center),
            ],
            const SizedBox(height: 28),
            _buildCard(0, Icons.touch_app, 'Normal Mode', 'Use touch screen to navigate and vote'),
            const SizedBox(height: 16),
            _buildCard(1, Icons.accessibility_new, 'Visually Impaired Mode', 'Voice guidance with keyboard navigation'),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.maybePop(context),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: const Text('Back', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _selectedMode >= 0 ? _proceed : null,
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
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

  Widget _buildCard(int index, IconData icon, String title, String desc) {
    final sel = _selectedMode == index;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => setState(() => _selectedMode = index),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: sel ? Colors.blue.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: sel ? VotRiteTheme.primaryBlue : Colors.grey.shade300, width: sel ? 2 : 1),
        ),
        child: Row(
          children: [
            Icon(icon, size: 40, color: sel ? VotRiteTheme.primaryBlue : VotRiteTheme.darkGray),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: sel ? VotRiteTheme.primaryBlue : VotRiteTheme.darkGray)),
                  const SizedBox(height: 4),
                  Text(desc, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                ],
              ),
            ),
            Icon(sel ? Icons.radio_button_checked : Icons.radio_button_off, color: sel ? VotRiteTheme.primaryBlue : Colors.grey),
          ],
        ),
      ),
    );
  }
}
