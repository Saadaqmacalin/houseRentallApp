import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

// Fasalkaani wuxuu maamulaa nidaamka lacag bixinta (Payment System)
class PaymentProvider with ChangeNotifier {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  // Shaqadan waxay fulisaa bixinta lacagta kirada (Process Payment)
  Future<bool> createPayment(String bookingId, double amount, String paymentMethod, String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/payments'),
        headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'bookingId': bookingId,
          'amount': amount,
          'paymentMethod': paymentMethod,
        }),
      ).timeout(const Duration(seconds: 45));

      if (response.statusCode == 201) {
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

  // Shaqadan waxay soo kaxaysaa taariikhda lacag bixinta ee qofka (Fetch Payment History)
  Future<List<dynamic>> fetchMyPayments(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/payments'),
        headers: {
            'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 45));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data; // Waxay soo celinaysaa liiska lacag bixinta
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
