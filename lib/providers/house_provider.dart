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

  Future<void> fetchHouses({
    String? address,
    double? minPrice,
    double? maxPrice,
    String? houseType,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      String query = 'status=available';
      if (address != null && address.isNotEmpty) query += '&address=${Uri.encodeComponent(address)}';
      if (minPrice != null) query += '&minPrice=$minPrice';
      if (maxPrice != null) query += '&maxPrice=$maxPrice';
      if (houseType != null && houseType != 'All') query += '&houseType=$houseType';

      final url = '${ApiConstants.baseUrl}/houses?$query';
      print('Fetching houses from: $url');
      final response = await http.get(Uri.parse(url));
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
      
      print('Fetch Favorites Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        // Safety filter: ensure json is not null and is a map
        return data
          .where((json) => json != null && json is Map<String, dynamic>)
          .map((json) => House.fromJson(json))
          .toList();
      } else {
        print('Fetch Favorites Failed: ${response.body}');
      }
      return [];
    } catch (e) {
      print('Fetch Favorites Error: $e');
      return [];
    }
  }
}
