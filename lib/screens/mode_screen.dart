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
    final provider = context.watch<VotingProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Mode'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0D47A1), Color(0xFF1565C0)],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.white,
              Colors.white,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              // Header with icon
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.how_to_vote, size: 32, color: VotRiteTheme.darkBlue),
                  const SizedBox(width: 12),
                  Text(
                    'How would you like to vote?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: VotRiteTheme.darkBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  provider.selectedBallot?.election ?? '',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 28),
              // Normal Mode card
              _buildModeCard(
                index: 0,
                icon: Icons.touch_app,
                title: 'Normal Mode',
                description: 'Use touch screen to navigate and vote',
                color: VotRiteTheme.primaryBlue,
              ),
              const SizedBox(height: 16),
              // Visually Impaired Mode card
              _buildModeCard(
                index: 1,
                icon: Icons.accessibility_new,
                title: 'Visually Impaired Mode',
                description: 'Voice guidance with keyboard navigation',
                color: const Color(0xFF2E7D32),
              ),
              const Spacer(),
              // Navigation buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.maybePop(context),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back', style: TextStyle(fontSize: 16)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey.shade400),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _selectedMode >= 0 ? _proceed : null,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Next'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
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

  Widget _buildModeCard({
    required int index,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    final isSelected = _selectedMode == index;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedMode = index);
        if (index == 1) {
          TtsService().speakAlways(
              'Visually Impaired mode selected. Voice guidance will be enabled.');
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.15) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                size: 32,
                color: isSelected ? color : VotRiteTheme.darkGray,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? color : VotRiteTheme.darkGray,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 18),
              )
            else
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400, width: 2),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
