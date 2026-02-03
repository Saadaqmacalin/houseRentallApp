import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'owner_dashboard_screen.dart';
import 'houses/owner_houses_screen.dart';
import 'tenants/tenant_management_screen.dart';
import 'owner_profile_screen.dart';
import 'houses/add_house_screen.dart';
import '../../utils/constants.dart';

class OwnerMainScreen extends StatefulWidget {
  const OwnerMainScreen({super.key});

  @override
  State<OwnerMainScreen> createState() => _OwnerMainScreenState();
}

class _OwnerMainScreenState extends State<OwnerMainScreen> {
  int _selectedIndex = 0;
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
  final GlobalKey<OwnerHousesScreenState> _housesKey = GlobalKey<OwnerHousesScreenState>();
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      OwnerDashboardScreen(onTabChange: (index) {
        setState(() => _selectedIndex = index);
        _bottomNavigationKey.currentState?.setPage(index);
      }),
      OwnerHousesScreen(key: _housesKey),
      const TenantManagementScreen(key: ValueKey('tenants')),
      const OwnerProfileScreen(key: ValueKey('profile')),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          Icon(Icons.dashboard_rounded, size: 30, color: Colors.white),
          Icon(Icons.home_work_rounded, size: 30, color: Colors.white),
          Icon(Icons.people_alt_rounded, size: 30, color: Colors.white),
          Icon(Icons.person_rounded, size: 30, color: Colors.white),
        ],
        index: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        animationDuration: const Duration(milliseconds: 300),
        animationCurve: Curves.easeInOut,
      ),
      floatingActionButton: _selectedIndex == 1 
        ? FloatingActionButton.extended(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddHouseScreen()),
              );
              if (result == true) {
                _housesKey.currentState?.fetchHouses();
              }
            },
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: const Text('Add Property', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          )
        : null,
    );
  }
}
