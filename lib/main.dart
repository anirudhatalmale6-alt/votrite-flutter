import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/voting_provider.dart';
import 'screens/splash_screen.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VotRiteApp());
}

class VotRiteApp extends StatelessWidget {
  const VotRiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VotingProvider(),
      child: Consumer<VotingProvider>(
        builder: (context, provider, _) {
          return MaterialApp(
            title: 'VotRite',
            debugShowCheckedModeBanner: false,
            theme: provider.accessibilityMode
                ? VotRiteTheme.accessibilityTheme
                : VotRiteTheme.lightTheme,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
