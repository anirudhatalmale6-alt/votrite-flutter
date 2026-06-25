import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/voting_provider.dart';
import '../services/tts_service.dart';
import '../theme.dart';
import 'help_screen.dart';
import 'race_screen.dart';
import 'finish_screen.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final _focusNode = FocusNode();
  int _highlightedIndex = -1;

  @override
  void initState() {
    super.initState();
    _announceReview();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _announceReview() {
    final provider = context.read<VotingProvider>();
    TtsService().speak(
      'Review your votes. ${provider.raceResults.length} races. '
      'Arrow keys to navigate, S to hear details, F to change a vote, J to cast ballot.',
    );
  }

  Future<void> _castBallot() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cast Your Ballot'),
        content: const Text(
          'Are you sure you want to submit your votes? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: VotRiteTheme.successGreen),
            child: const Text('Cast Ballot'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    TtsService().speak('Submitting your votes. Please wait.');
    final provider = context.read<VotingProvider>();
    final success = await provider.submitAllVotes();

    if (!mounted) return;
    if (success) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const FinishScreen()),
        (route) => false,
      );
    } else {
      TtsService().speak('Error submitting votes. Please try again.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit. Please try again.')),
      );
    }
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    final provider = context.read<VotingProvider>();
    final totalItems = provider.raceResults.length + provider.propositions.length;

    if (key == LogicalKeyboardKey.arrowDown || key == LogicalKeyboardKey.keyK) {
      setState(() {
        _highlightedIndex = (_highlightedIndex + 1).clamp(0, totalItems - 1);
      });
      _announceItem(_highlightedIndex);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowUp) {
      setState(() {
        _highlightedIndex = (_highlightedIndex - 1).clamp(0, totalItems - 1);
      });
      _announceItem(_highlightedIndex);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.keyF) {
      if (_highlightedIndex >= 0 && _highlightedIndex < provider.raceResults.length) {
        provider.goToRace(_highlightedIndex);
        Navigator.push(context, MaterialPageRoute(builder: (_) => const RaceScreen()));
      }
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.keyJ || key == LogicalKeyboardKey.enter) {
      _castBallot();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.keyD || key == LogicalKeyboardKey.escape) {
      Navigator.maybePop(context);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.keyS) {
      if (_highlightedIndex >= 0) {
        _announceItem(_highlightedIndex);
      } else {
        _announceReview();
      }
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.keyL) {
      TtsService().speak(
        'Review screen. Arrow keys to navigate. S to hear details. '
        'F to change a race vote. J or Enter to cast ballot.',
      );
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _announceItem(int index) {
    final provider = context.read<VotingProvider>();
    if (index < provider.raceResults.length) {
      final result = provider.raceResults[index];
      final names = result.selectedCandidates.map((c) => c.candidateName).join(', ');
      TtsService().speak(
        '${result.raceName}. ${names.isEmpty ? "No selection" : "Selected: $names"}. Press F to change.',
      );
    } else {
      final propIdx = index - provider.raceResults.length;
      if (propIdx < provider.propositions.length) {
        final prop = provider.propositions[propIdx];
        final vote = prop.vote == 1 ? prop.yesLabel : prop.vote == 2 ? prop.noLabel : 'No vote';
        TtsService().speak('${prop.propTitle}. Vote: $vote.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VotingProvider>();

    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKey,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Review Your Votes'),
          actions: [
            Semantics(
              label: 'Open accessibility help guide',
              button: true,
              child: IconButton(
                icon: const Icon(Icons.help_outline),
                onPressed: () => HelpScreen.show(context),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: VotRiteTheme.accentGold.withValues(alpha: 0.15),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, color: VotRiteTheme.darkBlue, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'Tap any item to change your vote',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'Races',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: VotRiteTheme.darkBlue),
                  ),
                  const SizedBox(height: 8),
                  ...provider.raceResults.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final result = entry.value;
                    final isHighlighted = idx == _highlightedIndex;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: isHighlighted
                            ? const BorderSide(color: VotRiteTheme.accentGold, width: 2)
                            : BorderSide.none,
                      ),
                      child: ListTile(
                        dense: true,
                        title: Text(
                          result.raceName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        subtitle: Text(
                          result.selectedCandidates.isEmpty
                              ? 'No selection'
                              : result.selectedCandidates.map((c) => c.candidateName).join(', '),
                          style: TextStyle(
                            fontSize: 12,
                            color: result.selectedCandidates.isEmpty
                                ? VotRiteTheme.errorRed
                                : VotRiteTheme.successGreen,
                          ),
                        ),
                        trailing: const Icon(Icons.edit, color: VotRiteTheme.primaryBlue, size: 20),
                        onTap: () {
                          provider.goToRace(idx);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const RaceScreen()),
                          );
                        },
                      ),
                    );
                  }),
                  if (provider.propositions.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Propositions',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: VotRiteTheme.darkBlue),
                    ),
                    const SizedBox(height: 8),
                    ...provider.propositions.asMap().entries.map((entry) {
                      final idx = entry.key + provider.raceResults.length;
                      final prop = entry.value;
                      final isHighlighted = idx == _highlightedIndex;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: isHighlighted
                              ? const BorderSide(color: VotRiteTheme.accentGold, width: 2)
                              : BorderSide.none,
                        ),
                        child: ListTile(
                          dense: true,
                          title: Text(
                            prop.propTitle,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          subtitle: Text(
                            prop.vote == 0
                                ? 'No vote'
                                : prop.vote == 1
                                    ? prop.yesLabel
                                    : prop.noLabel,
                            style: TextStyle(
                              fontSize: 12,
                              color: prop.vote == 0 ? VotRiteTheme.errorRed : VotRiteTheme.successGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onTap: () => setState(() => _highlightedIndex = idx),
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    onPressed: provider.isSubmitting ? null : _castBallot,
                    icon: provider.isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.how_to_vote),
                    label: Text(
                      provider.isSubmitting ? 'Submitting...' : 'Cast Ballot',
                      style: const TextStyle(fontSize: 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: VotRiteTheme.successGreen,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.maybePop(context),
                    child: const Text('Go Back', style: TextStyle(fontSize: 14)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
