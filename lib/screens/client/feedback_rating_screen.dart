import 'package:flutter/material.dart';
import '../../data/app_state.dart';
import '../../models/worker.dart';
import '../../navigation/nav.dart';
import '../../theme/app_theme.dart';

class FeedbackRatingScreen extends StatefulWidget {
  final Worker worker;
  const FeedbackRatingScreen({super.key, required this.worker});

  @override
  State<FeedbackRatingScreen> createState() => _FeedbackRatingScreenState();
}

class _FeedbackRatingScreenState extends State<FeedbackRatingScreen> {
  int _rating = 0;
  final _comment = TextEditingController();
  bool _submitted = false;
  bool _tipWorker = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rate Your Service'),
        automaticallyImplyLeading: false,
      ),
      body: _submitted
          ? _SubmittedView(onDone: () => Nav.toClient(context))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  const Text(
                    'How was your experience?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Service by ${widget.worker.name}',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      return IconButton(
                        iconSize: 44,
                        onPressed: () => setState(() => _rating = i + 1),
                        icon: Icon(
                          i < _rating ? Icons.star : Icons.star_border,
                          color: i < _rating
                              ? AppColors.rating
                              : AppColors.divider,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _rating == 0
                        ? 'Tap to rate'
                        : _rating <= 2
                            ? 'Poor experience'
                            : _rating == 3
                                ? 'Average'
                                : _rating == 4
                                    ? 'Good'
                                    : 'Excellent!',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _rating == 0
                          ? AppColors.textMuted
                          : AppColors.warning,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _comment,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Share details about your experience (optional)',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.volunteer_activism,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tip your worker',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Appreciate great service',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _tipWorker,
                            onChanged: (v) =>
                                setState(() => _tipWorker = v),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _rating == 0
                        ? null
                        : () {
                            setState(() => _submitted = true);
                            AppState.serviceCompleted.value = true;
                          },
                    child: const Text('Submit Review'),
                  ),
                ],
              ),
            ),
    );
  }
}

class _SubmittedView extends StatelessWidget {
  final VoidCallback onDone;
  const _SubmittedView({required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.thumb_up_alt,
              color: AppColors.success,
              size: 60,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Thank You!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Your review helps the community find reliable workers.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onDone,
            child: const Text('Back to Home'),
          ),
        ],
      ),
    );
  }
}
