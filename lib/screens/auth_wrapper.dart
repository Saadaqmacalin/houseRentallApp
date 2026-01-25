import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'auth/login_screen.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Only call tryAutoLogin once when the splash screen mounts
    await Provider.of<AuthProvider>(context, listen: false).tryAutoLogin();
    // After it completes, the Consumer in main.dart or the logic here could redirect.
    // But since main.dart uses Consumer, and tryAutoLogin calls notifyListeners,
    // we actually rely on the auth state changing.
  }

  @override
  Widget build(BuildContext context) {
    // Use Consumer to react to auth changes after tryAutoLogin completes
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        // If we are still "loading" (although tryAutoLogin logic might be sync or fast),
        // we can check auth.isAuthenticated.
        
        // Actually, tryAutoLogin updates user and notifies. 
        // If user is found, isAuthenticated becomes true.
        
        if (auth.isAuthenticated) {
          return const MainScreen();
        } else {
             // If we finished checking and no user, go to login.
             // We need a way to know if "checking" is done. 
             // Ideally AuthProvider should have an 'isAuthChecked' flag or similar.
             // For now, if we are in this builder and isAuthenticated is false, AND we assume tryAutoLogin finished...
             // But verify: has tryAutoLogin finished?
             // Since we await it in initState, this build method might run before or after.
             // To be safe, we can just return a loading indicator while a local future is running,
             // OR use a proper loading state in AuthProvider.
             
             // Let's use a simple FutureBuilder HERE instead of main.dart, 
             // OR just rely on the fact that we'll switch out of SplashScreen in the `home` widget?
             // No, `home` is SplashScreen.
             
             // Better approach: authentication wrapper.
             // But existing main.dart logic was:
             // home: FutureBuilder(...)
             
             // Creating a clean AuthWrapper is best.
             return const LoginScreen();
        }
      },
    );
  }
}

// Improved Approach: AuthWrapper that handles the "waiting" state properly.
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  late Future<void> _authFuture;

  @override
  void initState() {
    super.initState();
    _authFuture = Provider.of<AuthProvider>(context, listen: false).tryAutoLogin();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _authFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        
        // When done, check provider state
        return Consumer<AuthProvider>(
          builder: (context, auth, _) {
            return auth.isAuthenticated ? const MainScreen() : const LoginScreen();
          },
        );
      },
    );
  }
}
