import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/app_state.dart';
import '../../models/job.dart';
import '../../models/worker.dart';
import '../../navigation/nav.dart';
import '../../services/auth_service.dart';
import '../../services/job_service.dart';
import '../../theme/app_theme.dart';
import 'active_service_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final Worker worker;
  const OtpVerificationScreen({super.key, required this.worker});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  Timer? _timer;
  int _secondsLeft = 30;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _secondsLeft = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          if (_secondsLeft > 0) {
            _secondsLeft--;
          } else {
            _timer?.cancel();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  Future<void> _verifyAndCreateJob() async {
    final customerId = AuthService.currentUserId ??
        AppState.currentUserProfile.value?.id ??
        '';

    String? createdJobId;

    if (customerId.isNotEmpty) {
      final newJob = Job(
        id: '',
        workerId: widget.worker.id.length == 36 ? widget.worker.id : null,
        customerId: customerId,
        jobTitle: widget.worker.profession,
        description: 'Service request for ${widget.worker.profession}',
        status: 'in_progress',
        scheduledAt: DateTime.now(),
        amount: widget.worker.pricePerHour * 3,
        createdAt: DateTime.now(),
      );

      final created = await JobService.createJob(newJob);
      createdJobId = created?.id;
    }

    if (!mounted) return;
    AppState.currentBookingStatus.value = 'active';
    Nav.pushReplacement(
      context,
      ActiveServiceScreen(
        worker: widget.worker,
        jobId: createdJobId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Center(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified_user_outlined,
                  color: AppColors.primary,
                  size: 44,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Enter OTP',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'OTP sent to +91 98765 43210 to confirm booking with ${widget.worker.name}',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(4, (i) {
                return SizedBox(
                  width: 64,
                  height: 64,
                  child: TextField(
                    controller: _controllers[i],
                    focusNode: _focusNodes[i],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: const InputDecoration(
                      counterText: '',
                    ),
                    onChanged: (v) {
                      if (v.isNotEmpty && i < 3) {
                        _focusNodes[i + 1].requestFocus();
                      }
                    },
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: _secondsLeft > 0
                    ? null
                    : () {
                        _startTimer();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('A new OTP has been sent.'),
                          ),
                        );
                      },
                child: Text(
                  _secondsLeft > 0
                      ? 'Resend OTP ($_secondsLeft s)'
                      : 'Resend OTP',
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _verifyAndCreateJob,
              child: const Text('Verify OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
