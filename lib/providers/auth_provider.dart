import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../utils/constants.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/customer/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _user = User.fromJson(data);
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('userData', jsonEncode(data));
        notifyListeners();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/customer/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _user = User.fromJson(data);
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('userData', jsonEncode(data));
        notifyListeners();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('userData');
    notifyListeners();
  }

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) return;

    final extractedUserData = jsonDecode(prefs.getString('userData')!) as Map<String, dynamic>;
    _user = User.fromJson(extractedUserData);
    notifyListeners();
  }

  Future<void> toggleFavorite(String houseId) async {
    final oldFavorites = List<String>.from(_user!.favorites);
    try {
      // 1. Optimistic Update UI
      if (_user!.favorites.contains(houseId)) {
        _user!.favorites.remove(houseId);
      } else {
        _user!.favorites.add(houseId);
      }
      notifyListeners();

      // 2. Call API
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/customers/favorites/$houseId'),
        headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${_user!.token}',
        },
      );

      print('Toggle Favorite API Status: ${response.statusCode}');

      if (response.statusCode >= 400) {
        // Rollback on failure
        _user!.favorites = oldFavorites;
        notifyListeners();
        print('Toggle Favorite FAILED. Status: ${response.statusCode}');
        print('Error Body: ${response.body}');
      } else {
        // Success: Update state with data from server
        final List<dynamic> serverFavorites = jsonDecode(response.body);
        final newFavorites = serverFavorites.map((e) => e.toString()).toList();
        
        // Critical: Update the user object with the new list reference
        _user!.favorites = newFavorites;
        
        // Persist to local storage
        final prefs = await SharedPreferences.getInstance();
        if (prefs.containsKey('userData')) {
          final Map<String, dynamic> userData = jsonDecode(prefs.getString('userData')!);
          userData['favorites'] = newFavorites;
          prefs.setString('userData', jsonEncode(userData));
        }
        
        // Final notification to ensure UI is in sync
        notifyListeners();
        print('Favorite sync successful. Final count: ${newFavorites.length}');
      }
    } catch (e) {
      // Rollback on catch
      _user!.favorites = oldFavorites;
      notifyListeners();
      print('Toggle Favorite Exception: $e');
    }
  }
  Future<bool> updateProfile({String? name, String? email, String? password}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final Map<String, dynamic> updateData = {};
      if (name != null) updateData['name'] = name;
      if (email != null) updateData['email'] = email;
      if (password != null) updateData['password'] = password;

      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/customers/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_user!.token}',
        },
        body: jsonEncode(updateData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Important: Server might not return token on profile update, so keep current token
        final String currentToken = _user!.token;
        _user = User.fromJson(data);
        
        // Ensure token is preserved if it wasn't in the response
        if (_user!.token.isEmpty) {
          _user = User(
            id: _user!.id,
            name: _user!.name,
            email: _user!.email,
            token: currentToken,
            favorites: _user!.favorites,
          );
        }

        final prefs = await SharedPreferences.getInstance();
        final Map<String, dynamic> fullData = _user!.toJson();
        fullData['token'] = _user!.token; // Ensure token is persisted
        prefs.setString('userData', jsonEncode(fullData));
        
        notifyListeners();
        return true;
      } else {
        print('Update profile failed with status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Update profile exception: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
