import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/voting_provider.dart';
import '../services/tts_service.dart';
import '../theme.dart';
import 'race_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _pinController = TextEditingController();
  final _focusNode = FocusNode();
  final _pinFocusNode = FocusNode();
  bool _loading = false;
  String? _error;
  bool _obscurePin = true;

  @override
  void initState() {
    super.initState();
    _pinController.addListener(_onPinChanged);
    TtsService().speak('Enter your PIN code to begin voting. Type your PIN and press Enter or J to login.');
  }

  @override
  void dispose() {
    _pinController.removeListener(_onPinChanged);
    _pinController.dispose();
    _focusNode.dispose();
    _pinFocusNode.dispose();
    super.dispose();
  }

  void _onPinChanged() {
    final val = _pinController.text.trim();
    if (val.length == 4 && RegExp(r'^\d+$').hasMatch(val)) {
      TtsService().speak('PIN entered. Press Enter or J key to login.');
    }
  }

  Future<void> _login() async {
    final pin = _pinController.text.trim();
    if (pin.isEmpty) {
      setState(() => _error = 'Please enter your PIN code');
      TtsService().speak('Please enter your PIN code.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final provider = context.read<VotingProvider>();
    try {
      final result = await provider.validatePin(provider.selectedBallot!.ballotId, pin);
      if (!mounted) return;

      if (result == null) {
        setState(() {
          _loading = false;
          _error = 'Invalid PIN code. Please try again.';
        });
        TtsService().speak('Invalid PIN code. Please try again.');
        return;
      }

      final isUsed = result['is_used']?.toString() == 'true';
      if (isUsed) {
        setState(() {
          _loading = false;
          _error = 'This PIN has already been used.';
        });
        TtsService().speak('This PIN has already been used.');
        return;
      }

      provider.setPin(pin);
      await provider.loadRaces();
      await provider.loadPropositions();

      if (!mounted) return;
      TtsService().speak('PIN verified. Loading your ballot.');
      Navigator.push(context, MaterialPageRoute(builder: (_) => const RaceScreen()));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Connection error. Please try again.';
      });
      TtsService().speak('Connection error. Please try again.');
    }
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.keyJ) {
      if (_pinFocusNode.hasFocus) {
        _login();
        return KeyEventResult.handled;
      }
    }
    if (key == LogicalKeyboardKey.enter) {
      _login();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.keyD) {
      if (!_pinFocusNode.hasFocus) {
        Navigator.maybePop(context);
        return KeyEventResult.handled;
      }
    }
    if (key == LogicalKeyboardKey.keyL) {
      if (!_pinFocusNode.hasFocus) {
        TtsService().speak(
          'PIN login screen. Type your PIN code and press Enter or J to login. D to go back.',
        );
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VotingProvider>();

    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKey,
      child: Scaffold(
        appBar: AppBar(title: const Text('Enter PIN')),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline, size: 64, color: VotRiteTheme.primaryBlue),
                const SizedBox(height: 24),
                Text(
                  provider.selectedBallot?.election ?? 'Ballot',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enter your PIN code to begin voting',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: 280,
                  child: Semantics(
                    label: 'PIN code input',
                    child: TextField(
                      controller: _pinController,
                      focusNode: _pinFocusNode,
                      obscureText: _obscurePin,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 28, letterSpacing: 12),
                      maxLength: 10,
                      decoration: InputDecoration(
                        hintText: '----',
                        hintStyle: const TextStyle(letterSpacing: 12),
                        counterText: '',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: VotRiteTheme.primaryBlue, width: 2),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePin ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => _obscurePin = !_obscurePin),
                        ),
                      ),
                      onSubmitted: (_) => _login(),
                    ),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: VotRiteTheme.errorRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error, color: VotRiteTheme.errorRed),
                        const SizedBox(width: 8),
                        Text(_error!, style: const TextStyle(color: VotRiteTheme.errorRed)),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                SizedBox(
                  width: 280,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _login,
                    child: _loading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Login'),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.maybePop(context),
                  child: const Text('Back', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
