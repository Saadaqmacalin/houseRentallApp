import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/payment_provider.dart';
import '../providers/auth_provider.dart';
import 'package:intl/intl.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  late Future<List<dynamic>> _paymentsFuture;

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    _paymentsFuture = Provider.of<PaymentProvider>(context, listen: false).fetchMyPayments(auth.user!.token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transaction History')),
      body: FutureBuilder<List<dynamic>>(
        future: _paymentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
             return const Center(child: Text('Error loading transactions'));
          }
          final payments = snapshot.data ?? [];
          
          if (payments.isEmpty) {
            return const Center(child: Text('No transactions found.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: payments.length,
            separatorBuilder: (ctx, i) => const Divider(),
            itemBuilder: (context, index) {
              final payment = payments[index];
              final date = DateTime.parse(payment['paymentDate']);
              
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green.shade100,
                  foregroundColor: Colors.green.shade800,
                  child: const Icon(Icons.attach_money),
                ),
                title: Text('\$${payment['amount']}'),
                subtitle: Text(DateFormat('yyyy-MM-dd – kk:mm').format(date)),
                trailing: Chip(
                  label: Text(payment['paymentStatus'].toString().toUpperCase()),
                  backgroundColor: payment['paymentStatus'] == 'paid' ? Colors.green.shade100 : Colors.red.shade100,
                  labelStyle: TextStyle(
                    color: payment['paymentStatus'] == 'paid' ? Colors.green.shade800 : Colors.red.shade800,
                    fontSize: 12
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
