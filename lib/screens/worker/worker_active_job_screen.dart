import 'package:flutter/material.dart';
import '../../data/app_state.dart';
import '../../navigation/nav.dart';
import '../../theme/app_theme.dart';
import '../../widgets/status_badge.dart';

class WorkerActiveJobScreen extends StatefulWidget {
  const WorkerActiveJobScreen({super.key});

  @override
  State<WorkerActiveJobScreen> createState() =>
      _WorkerActiveJobScreenState();
}

class _WorkerActiveJobScreenState extends State<WorkerActiveJobScreen> {
  String _stage = 'otp'; // otp, in_progress, completed

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Active Job')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 26,
                      backgroundColor: Color(0xFF1B5E20),
                      child: Text(
                        'PM',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Priya Mehta',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            'Plumbing • Grant Road',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _stage == 'in_progress'
                        ? const StatusBadge(
                            label: 'In Progress',
                            color: Colors.green,
                            icon: Icons.build,
                          )
                        : const StatusBadge(
                            label: 'Confirmed',
                            color: Colors.blue,
                            icon: Icons.check_circle,
                          ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_stage == 'otp')
              _OtpSection(onVerify: () {
                setState(() => _stage = 'in_progress');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('OTP verified! Service started.'),
                  ),
                );
              })
            else if (_stage == 'in_progress')
              _ProgressSection(onComplete: () {
                setState(() => _stage = 'completed');
                AppState.workerCompletedJobs.value += 1;
                AppState.workerEarnings.value += 1050;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Service completed! ₹1,050 added to earnings.'),
                  ),
                );
              })
            else
              Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 64,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Job Completed!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '₹1,050 will be added to your earnings',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Nav.pop(context),
                      child: const Text('Done'),
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

class _OtpSection extends StatefulWidget {
  final VoidCallback onVerify;
  const _OtpSection({required this.onVerify});

  @override
  State<_OtpSection> createState() => _OtpSectionState();
}

class _OtpSectionState extends State<_OtpSection> {
  final List<TextEditingController> _c =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _f = List.generate(4, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _c) {
      c.dispose();
    }
    for (final x in _f) {
      x.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(Icons.shield_outlined, color: AppColors.primary),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Ask client to share the OTP to start the service',
                  style: TextStyle(
                    color: AppColors.primaryDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Enter OTP from client',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(4, (i) {
            return SizedBox(
              width: 60,
              height: 60,
              child: TextField(
                controller: _c[i],
                focusNode: _f[i],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
                decoration: const InputDecoration(counterText: ''),
                onChanged: (v) {
                  if (v.isNotEmpty && i < 3) _f[i + 1].requestFocus();
                },
              ),
            );
          }),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: widget.onVerify,
          child: const Text('Verify & Start Service'),
        ),
      ],
    );
  }
}

class _ProgressSection extends StatelessWidget {
  final VoidCallback onComplete;
  const _ProgressSection({required this.onComplete});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Service is in progress',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        const Text(
          'Keep client informed and maintain work quality.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        LinearProgressIndicator(
          value: 0.6,
          minHeight: 8,
          borderRadius: BorderRadius.circular(8),
          backgroundColor: AppColors.divider,
          color: AppColors.primary,
        ),
        const SizedBox(height: 8),
        const Text(
          '~60% completed • Elapsed 1h 48m',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          icon: const Icon(Icons.done_all),
          onPressed: onComplete,
          label: const Text('Mark Service Complete'),
        ),
      ],
    );
  }
}
