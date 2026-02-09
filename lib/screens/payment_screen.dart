import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/payment_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../services/receipt_service.dart';
import 'main_screen.dart';

class PaymentScreen extends StatelessWidget {
  final String bookingId;
  final double amount;
  final String houseAddress;
  final String ownerName;

  const PaymentScreen({
    super.key, 
    required this.bookingId, 
    required this.amount,
    required this.houseAddress,
    required this.ownerName,
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 28),
              SizedBox(width: 12),
              Text('Success'),
            ],
          ),
          content: const Text('Your payment was successful and your booking is confirmed!'),
          actions: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    ReceiptService.generateReceipt(
                      houseAddress: houseAddress,
                      ownerName: ownerName,
                      amount: amount,
                      paymentMethod: method,
                      bookingId: bookingId,
                    );
                  },
                  icon: const Icon(Icons.download_rounded),
                  label: const Text('Download Receipt', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const MainScreen()),
                      (route) => false,
                    );
                  },
                  child: const Text('Go Volume Home', style: TextStyle(color: AppColors.textLight)),
                ),
              ],
            ),
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Checkout', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Payment Details',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -1, color: AppColors.textDark),
            ),
            const SizedBox(height: 8),
            Text(
              houseAddress,
              style: TextStyle(color: AppColors.textLight, fontSize: 16),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: AppGradients.main,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [AppShadows.deep],
              ),
              child: Column(
                children: [
                  Text('Total Amount', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16)),
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
            Text(
              'Select Payment Method',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
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
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
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
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [AppShadows.soft],
        border: Border.all(color: AppColors.background),
      ),
      child: ListTile(
        onTap: isLoading ? null : onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
        trailing: Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textLight),
      ),
    );
  }
}
