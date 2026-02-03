import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'home/home_screen.dart';
import 'profile_screen.dart';
import 'favorites_screen.dart';
import 'transaction_history_screen.dart';
import '../utils/constants.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  final List<Widget> _screens = const [
    HomeScreen(),
    FavoritesScreen(),
    TransactionHistoryScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        backgroundColor: Colors.transparent,
        color: AppColors.primary,
        buttonBackgroundColor: AppColors.primary,
        height: 75.0,
        items: const <Widget>[
          Icon(Icons.home_rounded, size: 30, color: Colors.white),
          Icon(Icons.favorite_rounded, size: 30, color: Colors.white),
          Icon(Icons.receipt_long_rounded, size: 30, color: Colors.white),
          Icon(Icons.person_rounded, size: 30, color: Colors.white),
        ],
        index: _selectedIndex,
        onTap: (index) {
          if (_selectedIndex == index) return;
          setState(() {
            _selectedIndex = index;
          });
        },
        animationDuration: const Duration(milliseconds: 300),
        animationCurve: Curves.easeInOut,
      ),
    );
  }
}
