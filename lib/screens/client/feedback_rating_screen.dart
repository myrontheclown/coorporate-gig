import 'package:flutter/material.dart';
import '../../data/app_state.dart';
import '../../models/review.dart';
import '../../models/worker.dart';
import '../../navigation/nav.dart';
import '../../services/auth_service.dart';
import '../../services/review_service.dart';
import '../../services/worker_profile_service.dart';
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
  bool _submitting = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_submitting || _rating == 0) return;

    final customerId = AuthService.currentUserId ??
        AppState.currentUserProfile.value?.id ??
        '';

    if (customerId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to submit a review.')),
      );
      return;
    }

    setState(() => _submitting = true);

    // Resolve the real worker_profile UUID from Supabase so the review always
    // carries a valid worker_id (reviews.worker_id is NOT NULL in the schema).
    // Real workers keep their 36-char UUID; mock/short ids are resolved by
    // matching the currently selected/navigated worker by name or id.
    String? resolvedWorkerId;
    if (widget.worker.id.length == 36) {
      resolvedWorkerId = widget.worker.id;
    } else {
      final active = AppState.activeWorker;
      if (active != null && active.id.length == 36) {
        resolvedWorkerId = active.id;
      } else {
        try {
          final profiles = await WorkerProfileService.getWorkers();
          for (final p in profiles) {
            if (p.userProfile?.fullName == widget.worker.name ||
                p.id == widget.worker.id) {
              resolvedWorkerId = p.id;
              break;
            }
          }
        } catch (_) {
          // Ignore lookup errors — handled by the check below.
        }
      }
    }

    if (resolvedWorkerId == null || resolvedWorkerId.isEmpty) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not identify the worker. Please try again from the service list.',
          ),
        ),
      );
      return;
    }

    final review = Review(
      id: '',
      customerId: customerId,
      workerId: resolvedWorkerId,
      rating: _rating,
      comment: _comment.text.trim(),
      tipWorker: _tipWorker,
    );

    final created = await ReviewService.createReview(review);

    if (!mounted) return;

    setState(() {
      _submitting = false;
      _submitted = created != null;
    });

    AppState.serviceCompleted.value = true;

    if (created == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to submit review. Please try again.'),
        ),
      );
    }
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
                  if (_submitting)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else
                    ElevatedButton(
                      onPressed: _rating == 0 ? null : _submitReview,
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
