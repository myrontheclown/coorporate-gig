import 'package:flutter/material.dart';
import '../../data/app_state.dart';
import '../../models/worker.dart';
import '../../navigation/nav.dart';
import '../../theme/app_theme.dart';
import '../../widgets/circle_avatar.dart';
import '../../widgets/status_badge.dart';
import 'payment_screen.dart';

class ActiveServiceScreen extends StatefulWidget {
  final Worker worker;
  final String? jobId;
  const ActiveServiceScreen({super.key, required this.worker, this.jobId});

  @override
  State<ActiveServiceScreen> createState() => _ActiveServiceScreenState();
}

class _ActiveServiceScreenState extends State<ActiveServiceScreen> {
  int _elapsedMinutes = 0;
  String _serviceState = 'on_way'; // on_way, in_progress, awaiting_otp(complete)

  @override
  void initState() {
    super.initState();
    _startTimer();
    Future.delayed(const Duration(seconds: 8), () {
      if (mounted) setState(() => _serviceState = 'in_progress');
    });
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _elapsedMinutes++);
        _startTimer();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Service'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MapPlaceholder(
                    worker: widget.worker,
                    state: _serviceState,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                CircleAvatarImage(
                                  initials: widget.worker.avatarInitials,
                                  color: widget.worker.color,
                                  size: 48,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.worker.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        '${widget.worker.profession} • ${widget.worker.ratingLabel}★',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                _serviceState == 'on_way'
                                    ? const StatusBadge(
                                        label: 'On the way',
                                        color: Colors.blue,
                                        icon: Icons.directions_car,
                                      )
                                    : const StatusBadge(
                                        label: 'In Progress',
                                        color: Colors.green,
                                        icon: Icons.build,
                                      ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _ServiceTimer(minutes: _elapsedMinutes),
                        const SizedBox(height: 12),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              children: [
                                const _TimelineItem(
                                  icon: Icons.check_circle,
                                  color: Colors.green,
                                  title: 'Booking Confirmed',
                                  subtitle: 'OTP verified successfully',
                                ),
                                const SizedBox(height: 12),
                                _TimelineItem(
                                  icon: _serviceState == 'on_way'
                                      ? Icons.directions_car
                                      : Icons.check_circle,
                                  color: _serviceState == 'on_way'
                                      ? Colors.blue
                                      : Colors.green,
                                  title: 'Worker reached location',
                                  subtitle: _serviceState == 'on_way'
                                      ? 'Arriving in ~12 min'
                                      : 'Service started',
                                ),
                                const SizedBox(height: 12),
                                _TimelineItem(
                                  icon: _serviceState == 'in_progress'
                                      ? Icons.build
                                      : Icons.radio_button_unchecked,
                                  color: _serviceState == 'in_progress'
                                      ? AppColors.primary
                                      : AppColors.textMuted,
                                  title: 'Service in progress',
                                  subtitle: _serviceState == 'in_progress'
                                      ? 'Elapsed $_elapsedMinutes min'
                                      : 'Waiting to start',
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              children: [
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.call,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'Call Worker',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Spacer(),
                                    Icon(
                                      Icons.chevron_right,
                                      color: AppColors.textMuted,
                                    ),
                                  ],
                                ),
                                const Divider(height: 24),
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.chat_bubble_outline,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'Chat with Worker',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Spacer(),
                                    Icon(
                                      Icons.chevron_right,
                                      color: AppColors.textMuted,
                                    ),
                                  ],
                                ),
                                const Divider(height: 24),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.share_location_outlined,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Share location',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const Spacer(),
                                    Switch(value: true, onChanged: (_) {}),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_serviceState == 'in_progress')
            SafeArea(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 8,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.done_all),
                  onPressed: () {
                    setState(() => _serviceState = 'complete_pending');
                    AppState.serviceCompleted.value = true;
                    Nav.push(
                      context,
                      PaymentScreen(
                        worker: widget.worker,
                        jobId: widget.jobId,
                      ),
                    );
                  },
                  label: const Text('Complete Service'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MapPlaceholder extends StatelessWidget {
  final Worker worker;
  final String state;
  const _MapPlaceholder({required this.worker, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      width: double.infinity,
      color: const Color(0xFFE8EDF2),
      child: Stack(
        children: [
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.map_outlined,
                  color: Color(0xFFB0BEC5),
                  size: 60,
                ),
                const Text(
                  'Live Map View',
                  style: TextStyle(color: Color(0xFF90A4AE)),
                ),
                Text(
                  '${worker.locality}, Mumbai',
                  style: const TextStyle(
                    color: Color(0xFFB0BEC5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: const Column(
                children: [
                  Icon(Icons.navigation, color: Colors.blue),
                  SizedBox(height: 2),
                  Text(
                    '12 min',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Positioned(
            left: 40,
            bottom: 30,
            child: Icon(
              Icons.location_pin,
              color: Colors.red,
              size: 36,
            ),
          ),
          Positioned(
            right: 50,
            bottom: 40,
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white,
              child: Text(
                worker.avatarInitials,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: worker.color,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceTimer extends StatelessWidget {
  final int minutes;
  const _ServiceTimer({required this.minutes});

  @override
  Widget build(BuildContext context) {
    final h = (minutes ~/ 60).toString().padLeft(1, '0');
    final m = (minutes % 60).toString().padLeft(2, '0');
    final s = (0).toString().padLeft(2, '0');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const Icon(Icons.timer_outlined, color: AppColors.primary),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Service Duration',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Text(
              '$h:$m:$s',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  const _TimelineItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
