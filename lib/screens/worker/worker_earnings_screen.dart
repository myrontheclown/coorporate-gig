import 'package:flutter/material.dart';
import '../../data/app_state.dart';
import '../../models/transaction.dart';
import '../../services/transaction_service.dart';
import '../../theme/app_theme.dart';

class WorkerEarningsScreen extends StatefulWidget {
  const WorkerEarningsScreen({super.key});

  @override
  State<WorkerEarningsScreen> createState() => _WorkerEarningsScreenState();
}

class _WorkerEarningsScreenState extends State<WorkerEarningsScreen> {
  List<Transaction> _supabaseTransactions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final workerId = AppState.currentWorkerProfile.value?.id ?? '';
    if (workerId.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final txs = await TransactionService.getTransactionsForWorker(workerId);
      if (txs.isNotEmpty && mounted) {
        setState(() => _supabaseTransactions = txs);
      }
    } catch (_) {
      // Fallback
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showWithdraw(BuildContext context, int available) {
    final amountController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Withdraw Balance',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                'Available: ₹$available',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount (₹)',
                  prefixText: '₹ ',
                  hintText: 'Enter amount to withdraw',
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    final value = int.tryParse(amountController.text.trim()) ?? 0;
                    if (value <= 0 || value > available) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Enter a valid amount within your available balance.',
                          ),
                        ),
                      );
                      return;
                    }
                    Navigator.pop(ctx);
                    _showWithdrawSuccess(context, value);
                  },
                  child: const Text('Request Withdrawal'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showWithdrawSuccess(BuildContext context, int amount) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          icon: const Icon(Icons.check_circle, color: AppColors.success, size: 48),
          title: const Text('Withdrawal Requested'),
          content: Text(
            'Your request to withdraw ₹$amount has been submitted. Funds will '
            'be transferred to your linked bank account within 1–2 working days.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Earnings Help'),
          content: const Text(
            '• Earnings reflect approved completed jobs.\n'
            '• 50% of your earnings is available to withdraw instantly.\n'
            '• Payouts are processed within 1–2 working days.\n'
            '• Contact your cooperative admin for payout issues.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Got it'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalEarned = AppState.workerEarnings.value.toDouble();
    if (_supabaseTransactions.isNotEmpty) {
      totalEarned = _supabaseTransactions.fold<double>(
        0.0,
        (sum, item) => sum + item.amount,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Earnings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelp(context),
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
                    Text(
                      '₹${totalEarned.toInt().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},')}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const _InlineStat(value: '48', label: 'Jobs Done'),
                        const _InlineStat(value: '4.8★', label: 'Rating'),
                        const _InlineStat(value: '₹0', label: 'Pending'),
                        _InlineStat(
                          value: '₹${(totalEarned * 0.2).toInt()}',
                          label: 'This Week',
                        ),
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '₹${(totalEarned * 0.5).toInt()}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const Text(
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
                      onPressed: () =>
                          _showWithdraw(context, (totalEarned * 0.5).toInt()),
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
              child: _isLoading && _supabaseTransactions.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : Column(
                      children: _supabaseTransactions.isNotEmpty
                          ? _supabaseTransactions.map((tx) {
                              final dt = tx.createdAt ?? DateTime.now();
                              return Column(
                                children: [
                                  _Tx(
                                    title: 'Job Payment (${tx.paymentMethod})',
                                    amount: '+₹${tx.amount.toInt()}',
                                    date: '${dt.day}/${dt.month}/${dt.year}',
                                    color: AppColors.success,
                                  ),
                                  const Divider(height: 1),
                                ],
                              );
                            }).toList()
                          : const [
                              _Tx(
                                title: 'Plumbing - Priya M.',
                                amount: '+₹1,050',
                                date: '28 Aug',
                                color: AppColors.success,
                              ),
                              Divider(height: 1),
                              _Tx(
                                title: 'Pipe replacement - Sharma',
                                amount: '+₹900',
                                date: '29 Aug',
                                color: AppColors.success,
                              ),
                              Divider(height: 1),
                              _Tx(
                                title: 'Withdrawal to bank',
                                amount: '-₹5,000',
                                date: '27 Aug',
                                color: AppColors.error,
                              ),
                              Divider(height: 1),
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
  final List<double> _data = const [1.2, 2.4, 1.8, 3.2, 2.1, 4.0, 2.8];

  @override
  Widget build(BuildContext context) {
    const maxV = 4.0;
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
        const SizedBox(height: 24),
        Row(
          children: [
            _Legend(
              color: AppColors.primary.withValues(alpha: 0.6),
              label: 'Earned',
            ),
            const SizedBox(width: 16),
            const _Legend(color: AppColors.chartAccent, label: 'Best day'),
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
