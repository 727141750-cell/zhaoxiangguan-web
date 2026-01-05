import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://121.5.33.130:3001';
  static const int timeout = 30;

  static Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? body}) async {
    final url = '$baseUrl$path';
    debugPrint('API POST: $url');
    debugPrint('API Body: ${body != null ? jsonEncode(body) : "null"}');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body != null ? jsonEncode(body) : null,
      ).timeout(const Duration(seconds: timeout));

      debugPrint('API Response Status: ${response.statusCode}');
      debugPrint('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        debugPrint('API Decoded: $decoded');
        return decoded;
      } else {
        throw Exception('请求失败: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      debugPrint('API Error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> get(String path) async {
    final url = '$baseUrl$path';
    debugPrint('API GET: $url');

    final response = await http.get(
      Uri.parse(url),
    ).timeout(const Duration(seconds: timeout));

    debugPrint('API Response Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('请求失败: ${response.statusCode}');
    }
  }
}
