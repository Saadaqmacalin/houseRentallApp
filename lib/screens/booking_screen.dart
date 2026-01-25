import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/house.dart';
import '../providers/booking_provider.dart';
import '../providers/auth_provider.dart';
import 'payment_screen.dart';

class BookingScreen extends StatefulWidget {
  final House house;

  const BookingScreen({super.key, required this.house});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  final _formKey = GlobalKey<FormState>();

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _submit() async {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select both dates')));
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('End date must be after start date')));
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);

    final bookingId = await bookingProvider.createBooking(
      widget.house.id,
      _startDate!,
      _endDate!,
      auth.user!.token,
    );

    if (bookingId != null && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => PaymentScreen(bookingId: bookingId, amount: widget.house.price),
        ),
      );
    } else if (mounted) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
      final bookingProvider = Provider.of<BookingProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Book House')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Select Booking Dates for ${widget.house.address}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ListTile(
              title: Text(_startDate == null ? 'Select Start Date' : 'Start: ${DateFormat('yyyy-MM-dd').format(_startDate!)}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, true),
              tileColor: Colors.grey.shade100,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(_endDate == null ? 'Select End Date' : 'End: ${DateFormat('yyyy-MM-dd').format(_endDate!)}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, false),
              tileColor: Colors.grey.shade100,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
             const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: bookingProvider.isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: bookingProvider.isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Confirm Booking', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
