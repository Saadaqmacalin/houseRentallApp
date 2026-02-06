import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../providers/owner_auth_provider.dart';
import '../../../utils/constants.dart';
import 'add_house_screen.dart';

class OwnerHousesScreen extends StatefulWidget {
  const OwnerHousesScreen({super.key});

  @override
  State<OwnerHousesScreen> createState() => OwnerHousesScreenState();
}

class OwnerHousesScreenState extends State<OwnerHousesScreen> {
  List<dynamic> _houses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchHouses();
  }

  Future<void> fetchHouses() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final auth = Provider.of<OwnerAuthProvider>(context, listen: false);
    if (auth.owner == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/landlords/houses?limit=100'),
        headers: {
          'Authorization': 'Bearer ${auth.owner!.token}',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _houses = data['houses'] ?? [];
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load: ${response.statusCode}'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connection error'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteHouse(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Property?'),
        content: const Text('This action cannot be undone. All data related to this property will be removed.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep Property', style: TextStyle(color: AppColors.textLight))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true), 
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final auth = Provider.of<OwnerAuthProvider>(context, listen: false);
      if (auth.owner == null) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: Not authenticated'), backgroundColor: Colors.red));
        return;
      }
      try {
        final response = await http.delete(
          Uri.parse('${ApiConstants.baseUrl}/landlords/houses/$id'),
          headers: {
            'Authorization': 'Bearer ${auth.owner!.token}',
          },
        );

        if (response.statusCode == 200) {
          fetchHouses();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Property deleted'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text('My Properties', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
          centerTitle: true,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: Icon(Icons.refresh_rounded, color: AppColors.primary),
              onPressed: fetchHouses,
            ),
            const SizedBox(width: 8),
          ],
        ),
        Expanded(
          child: _isLoading 
            ? Center(child: CircularProgressIndicator(color: AppColors.primary))
            : RefreshIndicator(
                onRefresh: fetchHouses,
                color: AppColors.primary,
                child: _houses.isEmpty 
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 150),
                      itemCount: _houses.length,
                      itemBuilder: (context, index) {
                        final house = _houses[index];
                        return _buildHouseCard(house);
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
                child: Icon(Icons.home_work_rounded, size: 60, color: AppColors.primary.withOpacity(0.3)),
              ),
              const SizedBox(height: 24),
              const Text(
                'No listings found',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 8),
              Text(
                'Start by adding your first property\nto attract potential tenants.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textLight.withOpacity(0.7), fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHouseCard(Map<String, dynamic> house) {
    final status = house['status'] ?? 'available';
    final isBooked = status == 'booked';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [AppShadows.soft],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: Image.network(
                  house['imageUrl'] ?? 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6',
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary.withOpacity(0.3),
                            AppColors.accent.withOpacity(0.3),
                          ],
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.home_work_rounded, size: 50, color: AppColors.primary.withOpacity(0.5)),
                          const SizedBox(height: 8),
                          Text(
                            'Property Image',
                            style: TextStyle(color: AppColors.textDark.withOpacity(0.5), fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isBooked ? Colors.teal : (status == 'maintenance' ? Colors.orange : AppColors.accent),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [AppShadows.soft],
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.glassWhite,
                    shape: BoxShape.circle,
                  ),
                  child: PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert_rounded, color: AppColors.textDark),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    onSelected: (val) {
                      if (val == 'delete') _deleteHouse(house['_id']);
                      if (val == 'edit') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => AddHouseScreen(house: house)),
                        ).then((_) => fetchHouses());
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_rounded, size: 18, color: AppColors.textDark),
                            SizedBox(width: 8),
                            Text('Edit Info'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        house['address'] ?? '',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '\$${house['price']}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.king_bed_rounded, size: 16, color: AppColors.textLight.withOpacity(0.5)),
                    const SizedBox(width: 4),
                    Text('${house['numberOfRooms']} BR', style: const TextStyle(color: AppColors.textLight, fontSize: 13)),
                    const SizedBox(width: 16),
                    Icon(Icons.square_foot_rounded, size: 16, color: AppColors.textLight.withOpacity(0.5)),
                    const SizedBox(width: 4),
                    const Text('1,200 sqft', style: TextStyle(color: AppColors.textLight, fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
