import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../providers/owner_auth_provider.dart';
import '../../utils/constants.dart';

class OwnerDashboardScreen extends StatefulWidget {
  final Function(int)? onTabChange;
  const OwnerDashboardScreen({super.key, this.onTabChange});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    setState(() => _isLoading = true);
    final auth = Provider.of<OwnerAuthProvider>(context, listen: false);
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/landlords/stats'),
        headers: {
          'Authorization': 'Bearer ${auth.owner!.token}',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _stats = jsonDecode(response.body);
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load stats: ${response.statusCode}'), backgroundColor: Colors.red),
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

  @override
  Widget build(BuildContext context) {
    final owner = Provider.of<OwnerAuthProvider>(context).owner;

    return RefreshIndicator(
      onRefresh: _fetchStats,
      color: AppColors.primary,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          _buildSliverAppBar(owner),
          SliverToBoxAdapter(
            child: _isLoading 
              ? const Padding(
                  padding: EdgeInsets.only(top: 100),
                  child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                )
              : _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(dynamic owner) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppGradients.main,
          ),
          child: Stack(
            children: [
              Positioned(
                right: -50,
                top: -50,
                child: CircleAvatar(
                  radius: 100,
                  backgroundColor: AppColors.white.withOpacity(0.05),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 24, bottom: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back,',
                      style: TextStyle(color: AppColors.white.withOpacity(0.8), fontSize: 16),
                    ),
                    Text(
                      owner?.name ?? 'Owner',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.refresh_rounded, color: AppColors.white),
          onPressed: _fetchStats,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Financial Overview'),
          const SizedBox(height: 16),
          _buildFinancialStats(),
          const SizedBox(height: 32),
          _buildSectionTitle('Property Insights'),
          const SizedBox(height: 16),
          _buildPropertyStats(),
          const SizedBox(height: 32),
          _buildSectionTitle('Quick Actions'),
          const SizedBox(height: 16),
          _buildQuickActions(),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
    );
  }

  Widget _buildFinancialStats() {
    return Column(
      children: [
        _buildGradientStatCard(
          'Total Revenue', 
          '\$${_stats?['collectedThisMonth'] ?? 0}', 
          'Current Month',
          AppGradients.main,
          Icons.payments_rounded,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildLightStatCard(
              'Expected', 
              '\$${_stats?['expectedIncome'] ?? 0}', 
              Colors.blue, 
              Icons.account_balance_wallet_rounded,
            ),
            const SizedBox(width: 16),
            _buildLightStatCard(
              'Pending', 
              '${_stats?['unpaidRentCount'] ?? 0}', 
              Colors.orange, 
              Icons.hourglass_empty_rounded,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGradientStatCard(String title, String value, String subtitle, Gradient gradient, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [AppShadows.deep],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: AppColors.white.withOpacity(0.8), fontSize: 14)),
              const SizedBox(height: 8),
              Text(value, style: TextStyle(color: AppColors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(color: AppColors.white.withOpacity(0.6), fontSize: 12)),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.white, size: 30),
          ),
        ],
      ),
    );
  }

  Widget _buildLightStatCard(String title, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [AppShadows.soft],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            Text(title, style: TextStyle(color: AppColors.textLight, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyStats() {
    return Row(
      children: [
        _buildChipStat('Total', '${_stats?['totalHouses'] ?? 0}', AppColors.primary),
        const SizedBox(width: 12),
        _buildChipStat('Occupied', '${_stats?['rentedHouses'] ?? 0}', Colors.teal),
        const SizedBox(width: 12),
        _buildChipStat('Vacant', '${_stats?['vacantHouses'] ?? 0}', Colors.orange),
      ],
    );
  }

  Widget _buildChipStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: TextStyle(fontSize: 12, color: color.withOpacity(0.8), fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      children: [
        _buildActionTile(
          'Manage Listings', 
          'Add, edit, or remove your properties', 
          Icons.home_work_rounded, 
          Colors.indigo,
          () => widget.onTabChange?.call(1),
        ),
        const SizedBox(height: 12),
        _buildActionTile(
          'Tenant Reviews', 
          'Check feedback from your tenants', 
          Icons.star_outline_rounded, 
          Colors.amber,
          () => widget.onTabChange?.call(2), // Redirect to tenant management or elsewhere
        ),
      ],
    );
  }

  Widget _buildActionTile(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [AppShadows.soft],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(subtitle, style: TextStyle(color: AppColors.textLight, fontSize: 13)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
