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
    final oldFavorites = _user!.favorites; // Optimistic update
    try {
      if (_user!.favorites.contains(houseId)) {
        _user!.favorites.remove(houseId);
      } else {
        _user!.favorites.add(houseId);
      }
      notifyListeners();

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/customers/favorites/$houseId'),
        headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${_user!.token}', // Need token if using auth middleware
        },
      );

      if (response.statusCode >= 400) {
        _user!.favorites = oldFavorites;
        notifyListeners();
        print('Could not toggle favorite.');
      }
    } catch (e) {
      _user!.favorites = oldFavorites;
      notifyListeners();
      print(e);
    }
  }
}
