import 'package:flutter/material.dart';
import '../../data/app_state.dart';
import '../../data/mock_models.dart';
import '../../services/auth_service.dart';
import '../../services/job_service.dart';
import '../../services/supabase_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/circle_avatar.dart';
import '../../widgets/status_badge.dart';

class BookingsHistoryScreen extends StatefulWidget {
  const BookingsHistoryScreen({super.key});

  @override
  State<BookingsHistoryScreen> createState() => _BookingsHistoryScreenState();
}

class _BookingsHistoryScreenState extends State<BookingsHistoryScreen> {
  int _tab = 0;
  List<Booking> _supabaseBookings = [];
  bool _isLoading = false;
  bool _hasFetched = false;

  @override
  void initState() {
    super.initState();
    AppState.currentUserProfile.addListener(_onProfileChanged);
    _loadBookings();
  }

  @override
  void dispose() {
    AppState.currentUserProfile.removeListener(_onProfileChanged);
    super.dispose();
  }

  void _onProfileChanged() {
    if (mounted) {
      _loadBookings();
    }
  }

  Future<void> _loadBookings() async {
    final isAuthenticated =
        SupabaseService.isReady && AuthService.currentUser != null;

    if (!isAuthenticated) {
      if (mounted) {
        setState(() {
          _hasFetched = true;
          _supabaseBookings = MockModels.bookings;
        });
      }
      return;
    }

    final customerId = AuthService.currentUser!.id;

    setState(() => _isLoading = true);
    try {
      final jobs = await JobService.getJobsForCustomer(customerId);
      if (mounted) {
        setState(() {
          _hasFetched = true;
          _supabaseBookings = jobs.map((j) => j.toBooking()).toList();
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _hasFetched = true;
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Booking> get _currentList {
    final isAuthenticated =
        SupabaseService.isReady && AuthService.currentUser != null;
    final all = isAuthenticated
        ? _supabaseBookings
        : (_supabaseBookings.isNotEmpty
            ? _supabaseBookings
            : MockModels.bookings);

    switch (_tab) {
      case 0:
        // Active tab: shows active, pending, and in-progress jobs given by client
        return all
            .where((b) =>
                b.status == 'active' ||
                b.status == 'pending' ||
                b.status == 'in_progress')
            .toList();
      case 1:
        // Upcoming tab: confirmed / accepted scheduled jobs
        return all
            .where((b) =>
                b.status == 'confirmed' ||
                b.status == 'accepted')
            .toList();
      default:
        // History tab: completed and cancelled jobs
        return all
            .where((b) =>
                b.status == 'completed' || b.status == 'cancelled')
            .toList();
    }
  }

  String get _emptyMessage {
    switch (_tab) {
      case 0:
        return 'No active or pending bookings';
      case 1:
        return 'No upcoming bookings';
      default:
        return 'No completed booking history';
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = _currentList;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadBookings,
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Export invoices',
            onPressed: () => _showExportSheet(context, list),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _buildTabButton(label: 'Active', index: 0),
                _buildTabButton(label: 'Upcoming', index: 1),
                _buildTabButton(label: 'History', index: 2),
              ],
            ),
          ),
          Expanded(
            child: _isLoading && !_hasFetched
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadBookings,
                    child: list.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              const SizedBox(height: 100),
                              Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.calendar_month_outlined,
                                      size: 52,
                                      color: AppColors.textMuted,
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                      _emptyMessage,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                            itemCount: list.length,
                            itemBuilder: (context, i) {
                              return _BookingCard(booking: list[i]);
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({required String label, required int index}) {
    final selected = _tab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.divider,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
void _showExportSheet(BuildContext context, List<Booking> bookings) {
    final total = bookings.fold<double>(0, (sum, b) => sum + b.amount);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Export Invoices',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  '${bookings.length} booking${bookings.length == 1 ? '' : 's'} in this view',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                _DetailRow(
                  icon: Icons.request_quote_outlined,
                  label: 'Total billed',
                  value: '₹${total.toInt()}',
                ),
                _DetailRow(
                  icon: Icons.picture_as_pdf_outlined,
                  label: 'Format',
                  value: 'PDF document',
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.download_outlined),
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Invoices queued — check your downloads shortly.',
                          ),
                        ),
                      );
                    },
                    label: const Text('Download Invoices'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Booking booking;
  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatarImage(
                  initials: booking.avatarInitials,
                  color: booking.color,
                  size: 44,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.workerName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        booking.profession,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusBadge(
                  label: booking.statusLabel,
                  color: booking.statusColor,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 6),
                Text(
                  '${booking.date.day} ${_month(booking.date.month)} ${booking.date.year}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 14),
                const Icon(
                  Icons.schedule,
                  size: 14,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 6),
                Text(
                  booking.timeSlot,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    booking.address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  '₹${booking.amount.toInt()}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
                const Spacer(),
                if (booking.status == 'active')
                  FilledButton.tonal(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => _showTrack(context, booking),
                    child: const Text('Track'),
                  )
                else
                  TextButton(
                    onPressed: () => _showDetails(context, booking),
                    child: const Text('View Details'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDetails(BuildContext context, Booking booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatarImage(
                      initials: booking.avatarInitials,
                      color: booking.color,
                      size: 48,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.workerName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            booking.profession,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    StatusBadge(label: booking.statusLabel, color: booking.statusColor),
                  ],
                ),
                const SizedBox(height: 20),
                _DetailRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Date & time',
                  value:
                      '${booking.date.day} ${_month(booking.date.month)} ${booking.date.year} • ${booking.timeSlot}',
                ),
                _DetailRow(
                  icon: Icons.location_on_outlined,
                  label: 'Address',
                  value: booking.address,
                ),
                _DetailRow(
                  icon: Icons.currency_rupee,
                  label: 'Amount',
                  value: '₹${booking.amount.toInt()}',
                ),
                _DetailRow(
                  icon: Icons.payment_outlined,
                  label: 'Payment',
                  value: booking.paymentStatus,
                ),
                _DetailRow(
                  icon: Icons.receipt_long_outlined,
                  label: 'Booking ID',
                  value: booking.id,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTrack(BuildContext context, Booking booking) {
    const steps = [
      (Icons.check_circle, 'Booking confirmed', 'Worker accepted your request'),
      (Icons.local_shipping_outlined, 'On the way', 'Heading to your location'),
      (Icons.build_circle_outlined, 'In progress', 'Job in progress at your place'),
      (Icons.flag_outlined, 'Completed', 'Task finished and billed'),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatarImage(
                      initials: booking.avatarInitials,
                      color: booking.color,
                      size: 48,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.workerName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            booking.profession,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Live job status',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                for (var i = 0; i < steps.length; i++)
                  _TrackStep(
                    icon: steps[i].$1,
                    title: steps[i].$2,
                    subtitle: steps[i].$3,
                    isActive: i == 1,
                    isDone: i < 1,
                    isLast: i == steps.length - 1,
                  ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _month(int m) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return (m >= 1 && m <= 12) ? months[m - 1] : '';
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackStep extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isActive;
  final bool isDone;
  final bool isLast;

  const _TrackStep({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isActive,
    required this.isDone,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDone
        ? AppColors.success
        : isActive
            ? AppColors.primary
            : AppColors.textMuted;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Icon(icon, color: color, size: 24),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: isDone ? AppColors.success : AppColors.divider,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isActive || isDone
                          ? AppColors.textPrimary
                          : AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
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
          ),
        ],
      ),
    );
  }
}
