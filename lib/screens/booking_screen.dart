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

    final result = await bookingProvider.createBooking(
      widget.house.id,
      _startDate!,
      _endDate!,
      auth.user!.token,
    );

    if (result['success'] && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => PaymentScreen(
            bookingId: result['id'], 
            amount: widget.house.price,
            houseAddress: widget.house.address,
          ),
        ),
      );
    } else if (mounted) {
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'])));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Book Your Home'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Dates',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -1),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose your stay period for ${widget.house.address}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            const SizedBox(height: 32),
            _buildDateTile(
              context,
              title: 'Start Date',
              date: _startDate,
              icon: Icons.calendar_today_outlined,
              onTap: () => _selectDate(context, true),
            ),
            const SizedBox(height: 20),
            _buildDateTile(
              context,
              title: 'End Date',
              date: _endDate,
              icon: Icons.event_available_outlined,
              onTap: () => _selectDate(context, false),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.deepPurple),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Price is calculated monthly. Total will be shown at payment.',
                      style: TextStyle(color: Colors.deepPurple, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: bookingProvider.isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 0,
                ),
                child: bookingProvider.isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Confirm Booking', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTile(BuildContext context, {required String title, required DateTime? date, required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.deepPurple),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                Text(
                  date == null ? 'Not Selected' : DateFormat('MMMM dd, yyyy').format(date),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Spacer(),
            Icon(Icons.edit_outlined, size: 20, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
