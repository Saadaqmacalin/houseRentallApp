import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../providers/owner_auth_provider.dart';
import '../../../utils/constants.dart';
import 'package:intl/intl.dart';

class TenantManagementScreen extends StatefulWidget {
  const TenantManagementScreen({super.key});

  @override
  State<TenantManagementScreen> createState() => _TenantManagementScreenState();
}

class _TenantManagementScreenState extends State<TenantManagementScreen> {
  List<dynamic> _tenants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTenants();
  }

  Future<void> _fetchTenants() async {
    setState(() => _isLoading = true);
    final auth = Provider.of<OwnerAuthProvider>(context, listen: false);
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/landlords/tenants'),
        headers: {
          'Authorization': 'Bearer ${auth.owner!.token}',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _tenants = jsonDecode(response.body);
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load tenants: ${response.statusCode}'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connection error. Please try again.'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsPaid(String bookingId, double amount) async {
    final auth = Provider.of<OwnerAuthProvider>(context, listen: false);
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/landlords/mark-paid/$bookingId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${auth.owner!.token}',
        },
        body: jsonEncode({
          'amount': amount,
          'paymentMethod': 'cash',
        }),
      );

      if (response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment marked as paid'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating),
          );
        }
        _fetchTenants();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to mark as paid'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          title: Text('Managed Tenants', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        Expanded(
          child: _isLoading 
            ? Center(child: CircularProgressIndicator(color: AppColors.primary))
            : RefreshIndicator(
                onRefresh: _fetchTenants,
                color: AppColors.primary,
                child: _tenants.isEmpty 
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
                      itemCount: _tenants.length,
                      itemBuilder: (context, index) {
                        final tenant = _tenants[index];
                        return _buildTenantCard(tenant);
                      },
                    ),
              ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Center(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  boxShadow: [AppShadows.soft],
                ),
                child: Icon(Icons.people_alt_rounded, size: 60, color: AppColors.primary.withOpacity(0.3)),
              ),
              const SizedBox(height: 24),
              const Text('No active tenants', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              const SizedBox(height: 8),
              Text('Your rented properties and their\ntenants will appear here.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textLight, fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTenantCard(Map<String, dynamic> data) {
    final customer = data['customer'];
    final house = data['house'];
    final status = data['latestPaymentStatus'] ?? 'unpaid';
    final isPaid = status == 'paid';

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [AppShadows.soft],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  customer['name'][0].toUpperCase(),
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(customer['name'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                    Text(customer['email'], style: TextStyle(fontSize: 13, color: AppColors.textLight)),
                  ],
                ),
              ),
              _buildStatusChip(status, isPaid),
            ],
          ),
          const SizedBox(height: 24),
          _buildDetailRow(Icons.location_on_rounded, 'Property', house['address']),
          const SizedBox(height: 12),
          _buildDetailRow(Icons.calendar_month_rounded, 'Started', DateFormat('MMM dd, yyyy').format(DateTime.parse(data['startDate']))),
          const SizedBox(height: 12),
          _buildDetailRow(Icons.payments_rounded, 'Monthly Rent', '\$${house['price']}'),
          
          if (!isPaid) ...[
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _markAsPaid(data['_id'], house['price'].toDouble()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text('Mark Month as Paid', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status, bool isPaid) {
    final color = isPaid ? Colors.teal : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary.withOpacity(0.5)),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: TextStyle(color: AppColors.textLight.withOpacity(0.7), fontSize: 14),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: AppColors.textDark, fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
