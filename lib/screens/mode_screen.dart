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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A2463), Color(0xFF1565C0), Color(0xFF0D47A1)],
          ),
        ),
        child: Stack(
          children: [
            // Red stripe top
            Positioned(
              top: 0, left: 0, right: 0,
              child: Container(height: 5, color: const Color(0xFFB31942)),
            ),
            Positioned(
              top: 8, left: 0, right: 0,
              child: Container(height: 2, color: const Color(0xFFB31942).withOpacity(0.4)),
            ),
            // Red stripe bottom
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(height: 5, color: const Color(0xFFB31942)),
            ),
            Positioned(
              bottom: 8, left: 0, right: 0,
              child: Container(height: 2, color: const Color(0xFFB31942).withOpacity(0.4)),
            ),
            // Corner stars
            Positioned(
              top: 20, left: 16,
              child: Icon(Icons.star, size: 14, color: Colors.white.withOpacity(0.08)),
            ),
            Positioned(
              top: 40, left: 32,
              child: Icon(Icons.star, size: 10, color: Colors.white.withOpacity(0.06)),
            ),
            Positioned(
              top: 20, right: 16,
              child: Icon(Icons.star, size: 14, color: Colors.white.withOpacity(0.08)),
            ),
            Positioned(
              top: 40, right: 32,
              child: Icon(Icons.star, size: 10, color: Colors.white.withOpacity(0.06)),
            ),
            // Main content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    // Stars row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        3,
                        (i) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Icon(Icons.star, size: 14, color: VotRiteTheme.accentGold.withOpacity(0.6)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Logo
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFB31942).withOpacity(0.25),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.15),
                            blurRadius: 30,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.asset(
                          'assets/images/votrite_logo.png',
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 100, height: 100,
                            color: VotRiteTheme.white,
                            child: const Icon(Icons.how_to_vote, size: 48, color: VotRiteTheme.darkBlue),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // VotRite title
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Colors.white, Color(0xFFE8E8E8), Colors.white],
                      ).createShader(bounds),
                      child: const Text(
                        'VotRite',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Heading with red accent lines
                    const Text(
                      'How would you like to vote?',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(width: 30, height: 2, color: const Color(0xFFB31942)),
                        const SizedBox(width: 10),
                        Text(
                          'SELECT YOUR MODE',
                          style: TextStyle(
                            fontSize: 11,
                            color: VotRiteTheme.accentGold.withOpacity(0.9),
                            letterSpacing: 3,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(width: 30, height: 2, color: const Color(0xFFB31942)),
                      ],
                    ),
                    const SizedBox(height: 28),
                    // Normal Mode card
                    _ModeCard(
                      icon: Icons.touch_app,
                      title: 'Normal Mode',
                      subtitle: 'Use touch screen to navigate and vote',
                      accentColor: VotRiteTheme.primaryBlue,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                    // Visually Impaired card
                    _ModeCard(
                      icon: Icons.accessibility_new,
                      title: 'Visually Impaired',
                      subtitle: 'Voice guidance with keyboard navigation',
                      accentColor: const Color(0xFFB31942),
                      onTap: () {
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
                    const Spacer(),
                    // Bottom stars
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        5,
                        (i) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(Icons.star, size: 12, color: VotRiteTheme.accentGold.withOpacity(0.4)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Company name
                    Text(
                      'Voterite Inc.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.5),
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton.icon(
                      icon: const Icon(Icons.arrow_back, color: Colors.white70, size: 18),
                      label: const Text('Back', style: TextStyle(fontSize: 15, color: Colors.white70)),
                      onPressed: () => Navigator.maybePop(context),
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;
  final VoidCallback onTap;

  const _ModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 6,
      shadowColor: accentColor.withOpacity(0.3),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: accentColor.withOpacity(0.2), width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [accentColor.withOpacity(0.15), accentColor.withOpacity(0.05)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: accentColor.withOpacity(0.2)),
                ),
                child: Icon(icon, size: 30, color: accentColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: accentColor == VotRiteTheme.primaryBlue
                            ? VotRiteTheme.darkBlue
                            : const Color(0xFF8B1A2B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_forward_ios, size: 16, color: accentColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
