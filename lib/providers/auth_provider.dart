import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../utils/constants.dart';

// inla xaqiijyo dadka isticmaalaya app-ka (Authentication)
// Markasta oo state is beddelo wuxuu waxaa lawacaa notifyListeners() si UI-ga loo updategareeyo
class AuthProvider with ChangeNotifier { 
  User? _user; // Xogta usrka hada ku jiro (logged in user)
  bool _isLoading = false; 

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null; //  hubin in qofku soo galay?

  
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/customer/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 45));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _user = User.fromJson(data);
        // in userka xogtiisa lagu keydiyo local storage (local storage)
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('userData', jsonEncode(data));
        notifyListeners();
        return true;
      } else {
        return false;
      }
    } catch (e) {
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
      ).timeout(const Duration(seconds: 45));

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
    prefs.remove('userData'); // in latirtiro local storage data
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
      
      if (_user!.favorites.contains(houseId)) {
        _user!.favorites.remove(houseId);
      } else {
        _user!.favorites.add(houseId);
      }
      notifyListeners();

      // 2. in xogta databaseka  la update gareeyo 
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/customers/favorites/$houseId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_user!.token}',
        },
      ).timeout(const Duration(seconds: 45));

      if (response.statusCode >= 400) {
        
        _user!.favorites = oldFavorites;
        notifyListeners();
      } else {
        
        final List<dynamic> serverFavorites = jsonDecode(response.body);
        final newFavorites = serverFavorites.map((e) => e.toString()).toList();
        _user!.favorites = newFavorites;
        
        // in xogta lagu keydiyo local storage
        final prefs = await SharedPreferences.getInstance();
        if (prefs.containsKey('userData')) {
          final Map<String, dynamic> userData = jsonDecode(prefs.getString('userData')!);
          userData['favorites'] = newFavorites;
          prefs.setString('userData', jsonEncode(userData));
        }
        notifyListeners();
      }
    } catch (e) {
      _user!.favorites = oldFavorites;
      notifyListeners();
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
      ).timeout(const Duration(seconds: 45));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String currentToken = _user!.token;
        _user = User.fromJson(data);
        
        
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
        fullData['token'] = _user!.token;
        prefs.setString('userData', jsonEncode(fullData));
        
        notifyListeners();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
