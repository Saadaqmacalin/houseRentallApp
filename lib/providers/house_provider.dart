import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/house.dart';
import '../utils/constants.dart';

class HouseProvider with ChangeNotifier {
  List<House> _houses = [];
  bool _isLoading = false;

  List<House> get houses => [..._houses];
  bool get isLoading => _isLoading;

  Future<void> fetchHouses() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse('${ApiConstants.baseUrl}/houses?status=available'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _houses = data.map((json) => House.fromJson(json)).toList();
      }
    } catch (e) {
      print(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<House>> fetchFavorites(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/customers/favorites'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => House.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print(e);
      return [];
    }
  }
}
