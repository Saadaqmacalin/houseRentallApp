import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/house_provider.dart';
import '../models/house.dart';
import '../utils/constants.dart';
import 'auth/login_screen.dart';
import 'home/home_screen.dart'; // To reuse HouseCard

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  Future<List<House>>? _favoritesFuture;
  List<String>? _lastFavoriteIds;

  @override
  void initState() {
    super.initState();
    // Initially loaded in didChangeDependencies or build
  }

  void _loadFavorites(String token, List<String> favoriteIds) {
    _lastFavoriteIds = List<String>.from(favoriteIds);
    _favoritesFuture = Provider.of<HouseProvider>(context, listen: false).fetchFavorites(token);
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    
    if (!auth.isAuthenticated) {
      return _buildLoginRequiredState();
    }

    final currentFavorites = auth.user?.favorites ?? [];

    // Trigger reload if favorites list changed or not yet loaded
    if (_favoritesFuture == null || !_isSameList(_lastFavoriteIds, currentFavorites)) {
      _loadFavorites(auth.user!.token, currentFavorites);
    }
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
                _loadFavorites(auth.user!.token, currentFavorites);
              });
              await _favoritesFuture;
            },
            child: FutureBuilder<List<House>>(
              future: _favoritesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting && (_favoritesFuture != null)) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }
                if (snapshot.hasError) {
                  return _buildErrorState(auth.user!.token, currentFavorites);
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

  bool _isSameList(List<String>? a, List<String> b) {
    if (a == null) return false;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
        if (a[i] != b[i]) return false;
    }
    return true;
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(), // Important for RefreshIndicator
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

  Widget _buildErrorState(String token, List<String> favoriteIds) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 48, color: Colors.red.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text('Error loading favorites', style: TextStyle(color: AppColors.textLight)),
          TextButton(
            onPressed: () => setState(() => _loadFavorites(token, favoriteIds)),
            child: const Text('Try Again', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginRequiredState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              boxShadow: [AppShadows.soft],
            ),
            child: Icon(Icons.lock_outline_rounded, size: 60, color: AppColors.primary.withOpacity(0.3)),
          ),
          const SizedBox(height: 24),
          const Text(
            'Login Required',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Please login to see and manage your favorite properties.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textLight.withOpacity(0.7), fontSize: 14),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Go to Login', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
