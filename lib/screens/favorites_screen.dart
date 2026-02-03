import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/house_provider.dart';
import '../models/house.dart';
import '../utils/constants.dart';
import 'home/home_screen.dart'; // To reuse HouseCard

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late Future<List<House>> _favoritesFuture;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  void _loadFavorites() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    _favoritesFuture = Provider.of<HouseProvider>(context, listen: false).fetchFavorites(auth.user!.token);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          title: const Text('Wishlist', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _loadFavorites();
              });
              await _favoritesFuture;
            },
            child: FutureBuilder<List<House>>(
              future: _favoritesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }
                if (snapshot.hasError) {
                  return _buildErrorState();
                }
                final houses = snapshot.data ?? [];
                
                if (houses.isEmpty) {
                  return _buildEmptyState();
                }
      
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
                  itemCount: houses.length,
                  itemBuilder: (context, index) {
                    return HouseCard(house: houses[index]);
                  },
                );
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
                child: Icon(Icons.favorite_border_rounded, size: 60, color: AppColors.primary.withOpacity(0.3)),
              ),
              const SizedBox(height: 24),
              const Text(
                'No favorites yet',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 8),
              Text(
                'Explore houses and tap the heart\nto save them for later.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textLight.withOpacity(0.7), fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 48, color: Colors.red.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text('Error loading favorites', style: TextStyle(color: AppColors.textLight)),
          TextButton(
            onPressed: () => setState(() => _loadFavorites()),
            child: const Text('Try Again', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
