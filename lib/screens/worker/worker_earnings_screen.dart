import 'package:flutter/material.dart';
import '../../data/app_state.dart';
import '../../theme/app_theme.dart';

class WorkerEarningsScreen extends StatelessWidget {
  const WorkerEarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Earnings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: AppColors.primary,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Earnings',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    ValueListenableBuilder<int>(
                      valueListenable: AppState.workerEarnings,
                      builder: (context, v, _) => Text(
                        '₹${v.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},')}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _InlineStat(value: '48', label: 'Jobs Done'),
                        _InlineStat(value: '4.8★', label: 'Rating'),
                        _InlineStat(value: '₹0', label: 'Pending'),
                        _InlineStat(value: '₹2,350', label: 'This Week'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Earnings - Last 7 Days',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: _Chart(),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Withdraw Balance',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(
                      Icons.account_balance_wallet,
                      color: AppColors.primary,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '₹12,500',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'Available in Gig Wallet',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(96, 44),
                      ),
                      onPressed: () {},
                      child: const Text('Withdraw'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Recent Transactions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  _Tx(
                    title: 'Plumbing - Priya M.',
                    amount: '+₹1,050',
                    date: '28 Aug',
                    color: AppColors.success,
                  ),
                  const Divider(height: 1),
                  _Tx(
                    title: 'Pipe replacement - Sharma',
                    amount: '+₹900',
                    date: '29 Aug',
                    color: AppColors.success,
                  ),
                  const Divider(height: 1),
                  _Tx(
                    title: 'Withdrawal to bank',
                    amount: '-₹5,000',
                    date: '27 Aug',
                    color: AppColors.error,
                  ),
                  const Divider(height: 1),
                  _Tx(
                    title: 'Sink repair - Verma',
                    amount: '+₹750',
                    date: '25 Aug',
                    color: AppColors.success,
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

class _InlineStat extends StatelessWidget {
  final String value;
  final String label;
  const _InlineStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _Chart extends StatelessWidget {
  final List<double> _data = [1.2, 2.4, 1.8, 3.2, 2.1, 4.0, 2.8];

  @override
  Widget build(BuildContext context) {
    final maxV = 4.0;
    return Column(
      children: [
        SizedBox(
          height: 120,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(_data.length, (i) {
              final h = _data[i] / maxV;
              final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: 120 * h,
                        decoration: BoxDecoration(
                          color: i == 5
                              ? AppColors.chartAccent
                              : AppColors.primary.withValues(alpha: 0.6),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        days[i],
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
        const Divider(height: 24),
        Row(
          children: [
            _Legend(color: AppColors.primary.withValues(alpha: 0.6), label: 'Earned'),
            const SizedBox(width: 16),
            _Legend(color: AppColors.chartAccent, label: 'Best day'),
          ],
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _Tx extends StatelessWidget {
  final String title;
  final String amount;
  final String date;
  final Color color;
  const _Tx({
    required this.title,
    required this.amount,
    required this.date,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontSize: 14)),
      subtitle: Text(
        date,
        style: const TextStyle(fontSize: 12),
      ),
      trailing: Text(
        amount,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          color: color,
          fontSize: 14,
        ),
      ),
    );
  }
}
