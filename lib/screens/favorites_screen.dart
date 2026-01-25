import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/house_provider.dart';
import '../models/house.dart';
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
    final auth = Provider.of<AuthProvider>(context, listen: false);
    _favoritesFuture = Provider.of<HouseProvider>(context, listen: false).fetchFavorites(auth.user!.token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Favorites')),
      body: RefreshIndicator(
        onRefresh: () async {
          final auth = Provider.of<AuthProvider>(context, listen: false);
          setState(() {
            _favoritesFuture = Provider.of<HouseProvider>(context, listen: false).fetchFavorites(auth.user!.token);
          });
          await _favoritesFuture;
        },
        child: FutureBuilder<List<House>>(
          future: _favoritesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
               return const Center(child: Text('Error loading favorites'));
            }
            final houses = snapshot.data ?? [];
            
            if (houses.isEmpty) {
              return ListView( // Needs to be scrollable for RefreshIndicator
                children: const [
                  SizedBox(height: 100),
                  Center(child: Text('No favorites yet.')),
                ],
              );
            }
  
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: houses.length,
              itemBuilder: (context, index) {
                return HouseCard(house: houses[index]);
              },
            );
          },
        ),
      ),
    );
  }
}
