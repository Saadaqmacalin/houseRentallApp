import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/payment_provider.dart';
import '../providers/auth_provider.dart';
import 'main_screen.dart';

class PaymentScreen extends StatelessWidget {
  final String bookingId;
  final double amount;
  final String houseAddress;

  const PaymentScreen({
    super.key, 
    required this.bookingId, 
    required this.amount,
    required this.houseAddress,
  });

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Payment Details',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -1),
            ),
            const SizedBox(height: 8),
            Text(
              houseAddress,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.deepPurple, Color(0xFF673AB7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text('Total Amount', style: TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(
                    '\$${amount.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'SECURE PAYMENT',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            const Text(
              'Select Payment Method',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildMethod(
              context,
              'Credit / Debit Card',
              Icons.credit_card_outlined,
              paymentProvider.isLoading,
              () => _processPayment(context, 'card'),
            ),
            _buildMethod(
              context,
              'Cash Payment',
              Icons.account_balance_wallet_outlined,
              paymentProvider.isLoading,
              () => _processPayment(context, 'cash'),
            ),
            _buildMethod(
              context,
              'Bank Transfer',
              Icons.account_balance_outlined,
              paymentProvider.isLoading,
              () => _processPayment(context, 'transfer'),
            ),
            if (paymentProvider.isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Center(child: CircularProgressIndicator(color: Colors.deepPurple)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethod(BuildContext context, String title, IconData icon, bool isLoading, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: ListTile(
        onTap: isLoading ? null : onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.deepPurple),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      ),
    );
  }
}
