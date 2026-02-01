import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/payment_provider.dart';
import '../providers/booking_provider.dart';
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
              final rawDate = payment['paymentDate'];
              final date = rawDate != null ? DateTime.parse(rawDate) : DateTime.now();
              
              final booking = payment['booking'];
              final houseAddress = (booking != null && booking['house'] != null) 
                  ? booking['house']['address'] 
                  : 'Property details unavailable';
              
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.deepPurple.shade50,
                  foregroundColor: Colors.deepPurple,
                  child: const Icon(Icons.receipt_long),
                ),
                title: Text(houseAddress, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('\$${payment['amount']} - ${payment['paymentMethod']}'),
                    Text(
                      DateFormat('MMM dd, yyyy • hh:mm a').format(date),
                      style: const TextStyle(fontSize: 12),
                    ),
                    if (booking != null && booking['bookingStatus'] == 'approved') ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                             final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Stop Renting'),
                                content: const Text('Are you sure you want to stop renting this house? It will become available for others.'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, true), 
                                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                                    child: const Text('Stop Renting'),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              final auth = Provider.of<AuthProvider>(context, listen: false);
                              final success = await Provider.of<BookingProvider>(context, listen: false)
                                  .endBooking(booking['_id'], auth.user!.token);
                              
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Renting stopped successfully'))
                                );
                                setState(() {
                                  _paymentsFuture = Provider.of<PaymentProvider>(context, listen: false)
                                      .fetchMyPayments(auth.user!.token);
                                });
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Failed to stop renting'))
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.stop_circle_outlined, size: 18),
                          label: const Text('Stop Renting'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 4),
                          ),
                        ),
                      ),
                    ]
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Chip(
                      label: Text(payment['paymentStatus'].toString().toUpperCase()),
                      backgroundColor: payment['paymentStatus'] == 'paid' ? Colors.green.shade100 : Colors.red.shade100,
                      labelStyle: TextStyle(
                        color: payment['paymentStatus'] == 'paid' ? Colors.green.shade800 : Colors.red.shade800,
                        fontSize: 12
                      ),
                    ),
                    if (booking != null && booking['bookingStatus'] == 'ended')
                       const Padding(
                         padding: EdgeInsets.only(top: 4),
                         child: Text('ENDED', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                       ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
