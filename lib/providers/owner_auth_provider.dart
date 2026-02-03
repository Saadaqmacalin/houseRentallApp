import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../utils/constants.dart';

class OwnerAuthProvider with ChangeNotifier {
  User? _owner;
  bool _isLoading = false;

  User? get owner => _owner;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _owner != null;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/landlord/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      print('Owner Login Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _owner = User.fromJson(data);
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('ownerData', jsonEncode(data));
        notifyListeners();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Owner Login Error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
    required String nationalID,
    required String address,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/landlord/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'phoneNumber': phoneNumber,
          'nationalID': nationalID,
          'address': address,
        }),
      );

      print('Owner Register Status: ${response.statusCode}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _owner = User.fromJson(data);
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('ownerData', jsonEncode(data));
        notifyListeners();
        return true;
      } else {
        print('Owner Register Failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Owner Register Exception: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _owner = null;
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('ownerData');
    notifyListeners();
  }

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('ownerData')) return;

    final extractedOwnerData = jsonDecode(prefs.getString('ownerData')!) as Map<String, dynamic>;
    _owner = User.fromJson(extractedOwnerData);
    notifyListeners();
  }

  Future<bool> updateProfile({String? name, String? email, String? password, String? phoneNumber, String? address, String? nationalID}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final Map<String, dynamic> updateData = {};
      if (name != null) updateData['name'] = name;
      if (email != null) updateData['email'] = email;
      if (password != null) updateData['password'] = password;
      if (phoneNumber != null) updateData['phoneNumber'] = phoneNumber;
      if (address != null) updateData['address'] = address;
      if (nationalID != null) updateData['nationalID'] = nationalID;

      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/landlords/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_owner!.token}',
        },
        body: jsonEncode(updateData),
      );

      print('Owner Profile Update Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _owner = User.fromJson(data);
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('ownerData', jsonEncode(data));
        notifyListeners();
        return true;
      } else {
        print('Owner Profile Update Failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Owner Profile Update Exception: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
