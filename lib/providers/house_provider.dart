import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/house.dart';
import '../utils/constants.dart';

// Fasalkaani wuxuu maamulaa xogta guryaha la kiraynayo (House Listings)
class HouseProvider with ChangeNotifier {
  List<House> _houses = []; // Liiska guryaha la helay
  bool _isLoading = false;

  List<House> get houses => [..._houses];
  bool get isLoading => _isLoading;

  // Shaqadan waxay soo kaxaysaa guryaha (Fetch Houses) iyadoo la adeegsanayo shaandheyn (Filters)
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

      final url = '${ApiConstants.baseUrl}/houses?$query&limit=50';
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 45));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> housesList = responseData['houses'];
        _houses = housesList.map((json) => House.fromJson(json)).toList();
      }
    } catch (e) {
      print(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Shaqadan waxay soo kaxaysaa guryaha uu qofku 'Favorite' ka dhigtay
  Future<List<House>> fetchFavorites(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/customers/favorites'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 45));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
          .where((json) => json != null && json is Map<String, dynamic>)
          .map((json) => House.fromJson(json))
          .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
