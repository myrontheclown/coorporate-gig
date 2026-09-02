import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../data/app_state.dart';
import '../../models/worker.dart';
import '../../navigation/nav.dart';
import '../../theme/app_theme.dart';
import '../../widgets/circle_avatar.dart';
import 'booking_confirmation_screen.dart';

class MatchingEngineScreen extends StatefulWidget {
  final Worker worker;
  const MatchingEngineScreen({super.key, required this.worker});

  @override
  State<MatchingEngineScreen> createState() => _MatchingEngineScreenState();
}

class _MatchingEngineScreenState extends State<MatchingEngineScreen> {
  int _step = 0;
  late List<Worker> _matches;
  Worker? _finalMatch;

  @override
  void initState() {
    super.initState();
    // The cosmetic animation shows similar mock workers, but the ACTUAL
    // engaged worker is always the real one the customer selected — its UUID
    // must carry through to the job, transaction, and review records.
    _matches = MockData.workers.where((w) =>
        w.profession.toLowerCase() ==
        widget.worker.profession.toLowerCase()).toList();
    if (_matches.isEmpty) _matches = [...MockData.workers].take(3).toList();
    _runMatching();
  }

  Future<void> _runMatching() async {
    for (int i = 1; i <= 5; i++) {
      await Future.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
      setState(() => _step = i);
    }
    setState(() {
      // Keep the real worker identity (id, coordinates, profile) throughout.
      _finalMatch = widget.worker;
    });
    AppState.activeWorker = _finalMatch;
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    Nav.pushReplacement(
      context,
      BookingConfirmationScreen(worker: _finalMatch!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finding Your Match'),
        automaticallyImplyLeading: false,
      ),
      body: _finalMatch == null
          ? Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Matching Engine',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Analyzing workers in your area...',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 30),
                  _MatchingAnimation(step: _step, matches: _matches),
                  const Spacer(),
                  _StepStatus(step: _step),
                  const SizedBox(height: 24),
                ],
              ),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 72,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Worker Matched!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CircleAvatarImage(
                    initials: _finalMatch!.avatarInitials,
                    color: _finalMatch!.color,
                    size: 72,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _finalMatch!.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    _finalMatch!.profession,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star,
                          color: AppColors.rating, size: 18),
                      Text(
                        ' ${_finalMatch!.ratingLabel} • ${_finalMatch!.reviews} reviews',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Match Score: 96%',
                    style: TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _MatchingAnimation extends StatelessWidget {
  final int step;
  final List<Worker> matches;
  const _MatchingAnimation({required this.step, required this.matches});

  @override
  Widget build(BuildContext context) {
    final visible = step == 0 ? 3 : (step > matches.length ? matches.length : step + 1);
    int shown = visible.clamp(0, matches.length);
    final top = matches.take(shown).toList();
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: CircularProgressIndicator(
                value: step / 5,
                strokeWidth: 8,
                backgroundColor: AppColors.divider,
                color: AppColors.primary,
              ),
            ),
            Column(
              children: [
                Text(
                  '${(step / 5 * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
                const Text(
                  'matching',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (top.isNotEmpty)
          Column(
            children: top.map((w) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      CircleAvatarImage(
                        initials: w.avatarInitials,
                        color: w.color,
                        size: 32,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          w.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Text(
                        '${(94 + top.indexOf(w)).clamp(90, 99)}%',
                        style: const TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}

class _StepStatus extends StatelessWidget {
  final int step;
  const _StepStatus({required this.step});

  final _steps = const [
    'Fetching nearby workers',
    'Filtering by skills',
    'Checking availability',
    'Verifying ratings',
    'Running AI recommendation',
  ];

  @override
  Widget build(BuildContext context) {
    final current = step.clamp(1, _steps.length);
    return Column(
      children: [
        for (int i = 0; i < _steps.length; i++)
          ListTile(
            dense: true,
            leading: Icon(
              i < current
                  ? Icons.check_circle
                  : i == current
                      ? Icons.hourglass_top
                      : Icons.circle_outlined,
              color: i < current
                  ? AppColors.success
                  : i == current
                      ? AppColors.primary
                      : AppColors.divider,
            ),
            title: Text(
              _steps[i],
              style: TextStyle(
                fontWeight: i <= current ? FontWeight.w600 : FontWeight.w400,
                color: i <= current
                    ? AppColors.textPrimary
                    : AppColors.textMuted,
              ),
            ),
          ),
      ],
    );
  }
}
