import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class BookingProvider with ChangeNotifier {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<Map<String, dynamic>> createBooking(String houseId, DateTime startDate, DateTime endDate, String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/bookings'),
        headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'houseId': houseId,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        }),
      );

      print('Booking API Status: ${response.statusCode}');
      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {'success': true, 'id': data['_id']};
      } else {
        print('Booking API Failed: ${response.body}');
        return {'success': false, 'message': data['message'] ?? 'Booking failed'};
      }
    } catch (e) {
      print('Booking Exception: $e');
      return {'success': false, 'message': 'Connection error'};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<bool> endBooking(String bookingId, String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/bookings/$bookingId/end'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final errorData = json.decode(response.body);
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
