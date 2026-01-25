import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/payment_provider.dart';
import '../providers/auth_provider.dart';
import 'main_screen.dart';

class PaymentScreen extends StatelessWidget {
  final String bookingId;
  final double amount;

  const PaymentScreen({super.key, required this.bookingId, required this.amount});

  void _processPayment(BuildContext context, String method) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);

    final success = await paymentProvider.createPayment(
      bookingId,
      amount,
      method,
      auth.user!.token,
    );

    if (success && context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('Payment Successful'),
          content: const Text('Your booking has been confirmed!'),
          actions: [
            TextButton(
              onPressed: () {
                 Navigator.of(context).pushAndRemoveUntil(
                   MaterialPageRoute(builder: (context) => const MainScreen()),
                   (route) => false,
                 );
              },
              child: const Text('Go Home'),
            )
          ],
        ),
      );
    } else if (context.mounted) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final paymentProvider = Provider.of<PaymentProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(child: Icon(Icons.payment, size: 80, color: Colors.blue)),
            const SizedBox(height: 16),
            Text('Amount to Pay', style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
            Text('\$${amount.toStringAsFixed(2)}', style: Theme.of(context).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.green), textAlign: TextAlign.center),
             const SizedBox(height: 48),
            Text('Select Payment Method', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            
            _buildMethod(context, 'Credit Card', Icons.credit_card, 'card', paymentProvider.isLoading, () => _processPayment(context, 'card')),
            const SizedBox(height: 16),
            _buildMethod(context, 'Cash', Icons.money, 'cash', paymentProvider.isLoading, () => _processPayment(context, 'cash')),
            const SizedBox(height: 16),
            _buildMethod(context, 'Bank Transfer', Icons.account_balance, 'transfer', paymentProvider.isLoading, () => _processPayment(context, 'transfer')),
          ],
        ),
      ),
    );
  }

  Widget _buildMethod(BuildContext context, String title, IconData icon, String methodKey, bool isLoading, VoidCallback onTap) {
      return InkWell(
          onTap: isLoading ? null : onTap,
          child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                  children: [
                      Icon(icon, color: Colors.blue),
                      const SizedBox(width: 16),
                      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  ],
              ),
          ),
      );
  }
}
