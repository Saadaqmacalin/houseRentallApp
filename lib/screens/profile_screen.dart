import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'auth/login_screen.dart';
import 'transaction_history_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    return Scaffold(
      body: user == null ? const Center(child: Text('Not logged in')) : 
      Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 80, bottom: 40),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Column(
                children: [
                    CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: Text(user.name[0].toUpperCase(), style: TextStyle(fontSize: 40, color: Theme.of(context).primaryColor)),
                    ),
                    const SizedBox(height: 16),
                    Text(user.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text(user.email, style: const TextStyle(color: Colors.white70)),
                ],
            ),
          ),
          
          Expanded(
              child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                      ListTile(
                          leading: const Icon(Icons.person),
                          title: const Text('Edit Profile'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {}, // TODO
                      ),
                      const Divider(),
                       ListTile(
                          leading: const Icon(Icons.history),
                          title: const Text('Transaction History'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                             Navigator.of(context).push(
                               MaterialPageRoute(builder: (context) => const TransactionHistoryScreen())
                             );
                          },
                      ),
                      const Divider(),
                      ListTile(
                          leading: const Icon(Icons.logout, color: Colors.red),
                          title: const Text('Logout', style: TextStyle(color: Colors.red)),
                          onTap: () {
                              Provider.of<AuthProvider>(context, listen: false).logout();
                              // Since MainScreen is controlled by AuthWrapper via provider state, logout should auto redirect.
                              // But explicit nav helps clean history.
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(builder: (context) => const LoginScreen()), 
                                  (route) => false
                              );
                          },
                      ),
                  ],
              ),
          ),
        ],
      ),
    );
  }
}
