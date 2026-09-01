import 'package:flutter/material.dart';
import '../../data/app_state.dart';
import '../../models/transaction.dart';
import '../../models/worker.dart';
import '../../navigation/nav.dart';
import '../../services/auth_service.dart';
import '../../services/job_service.dart';
import '../../services/transaction_service.dart';
import '../../theme/app_theme.dart';
import 'feedback_rating_screen.dart';

class PaymentScreen extends StatefulWidget {
  final Worker worker;
  final String? jobId;
  const PaymentScreen({super.key, required this.worker, this.jobId});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _method = 'UPI';
  bool _paid = false;

  Future<void> _processPayment(double total) async {
    setState(() {
      _paid = true;
      AppState.paymentMade.value = true;
    });

    final customerId = AuthService.currentUserId ??
        AppState.currentUserProfile.value?.id ??
        '';

    if (customerId.isNotEmpty) {
      if (widget.jobId != null && widget.jobId!.isNotEmpty) {
        await JobService.updateJobStatus(widget.jobId!, 'completed');
      }

      final newTx = Transaction(
        id: '',
        jobId: widget.jobId,
        customerId: customerId,
        workerId: widget.worker.id.length == 36 ? widget.worker.id : null,
        amount: total,
        paymentMethod: _method,
        status: 'completed',
        transactionReference: 'TXN${DateTime.now().millisecondsSinceEpoch}',
        createdAt: DateTime.now(),
      );

      await TransactionService.createTransaction(newTx);
    }

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Nav.pushReplacement(
          context,
          FeedbackRatingScreen(worker: widget.worker),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final labour = widget.worker.pricePerHour * 3;
    final fee = (labour * 0.05).roundToDouble();
    final total = labour + fee;

    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: _paid
          ? _PaymentSuccess(onDone: () => Nav.pop(context))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        children: [
                          _PriceRow(
                            label: 'Labour (3 hrs)',
                            value: '₹${labour.toInt()}',
                          ),
                          const SizedBox(height: 8),
                          _PriceRow(
                            label: 'Service Fee (5%)',
                            value: '₹${fee.toInt()}',
                          ),
                          const SizedBox(height: 8),
                          const Divider(),
                          const SizedBox(height: 8),
                          _PriceRow(
                            label: 'Total',
                            value: '₹${total.toInt()}',
                            bold: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Payment Method',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _PaymentMethodTile(
                    icon: Icons.qr_code,
                    label: 'UPI',
                    sub: 'GPay, PhonePe, Paytm',
                    selected: _method == 'UPI',
                    onTap: () => setState(() => _method = 'UPI'),
                  ),
                  _PaymentMethodTile(
                    icon: Icons.wallet_outlined,
                    label: 'Gig Wallet',
                    sub: 'Balance: ₹1,250',
                    selected: _method == 'Wallet',
                    onTap: () => setState(() => _method = 'Wallet'),
                  ),
                  _PaymentMethodTile(
                    icon: Icons.credit_card,
                    label: 'Card / Net Banking',
                    sub: 'Visa, Mastercard, RuPay',
                    selected: _method == 'Card',
                    onTap: () => setState(() => _method = 'Card'),
                  ),
                  _PaymentMethodTile(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'Cash on Completion',
                    sub: 'Pay at site',
                    selected: _method == 'Cash',
                    onTap: () => setState(() => _method = 'Cash'),
                  ),
                  const SizedBox(height: 20),
                  SafeArea(
                    child: ElevatedButton(
                      onPressed: () => _processPayment(total),
                      child: Text(
                        _method == 'Cash'
                            ? 'Complete & Mark Paid'
                            : 'Pay ₹${total.toInt()}',
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentMethodTile({
    required this.icon,
    required this.label,
    required this.sub,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      sub,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: selected ? AppColors.primary : AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  const _PriceRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: bold ? 16 : 14,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w400,
            color: bold ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: bold ? 18 : 14,
            fontWeight: FontWeight.w800,
            color: bold ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _PaymentSuccess extends StatelessWidget {
  final VoidCallback onDone;
  const _PaymentSuccess({required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 72,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Payment Successful!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Receipt sent to your email & phone',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onDone,
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
