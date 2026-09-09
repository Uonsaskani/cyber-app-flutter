import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const String apiBase = 'https://cyber-backend-1-xqz8.onrender.com/api';

class ApiService {
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body, {
    bool auth = false,
  }) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    final res = await http.post(
      Uri.parse('$apiBase$path'),
      headers: headers,
      body: jsonEncode(body),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode >= 400) {
      throw Exception(data['error'] ?? 'خطای ناشناخته');
    }
    return data;
  }

  static Future<Map<String, dynamic>> _get(String path,
      {bool auth = true}) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    final res = await http.get(Uri.parse('$apiBase$path'), headers: headers);
    final data = jsonDecode(res.body);
    if (res.statusCode >= 400) {
      throw Exception(data['error'] ?? 'خطای ناشناخته');
    }
    return data;
  }

  static Future<void> register(
      String fullName, String phone, String password) async {
    final data = await _post('/auth/register',
        {'fullName': fullName, 'phone': phone, 'password': password});
    await setToken(data['token']);
  }

  static Future<void> login(String phone, String password) async {
    final data =
        await _post('/auth/login', {'phone': phone, 'password': password});
    await setToken(data['token']);
  }

  static Future<bool> checkSubscription() async {
    try {
      final data = await _get('/subscription/status');
      return data['active'] == true;
    } catch (_) {
      return false;
    }
  }

  static Future<Map<String, dynamic>> requestPayment() async {
    return await _post('/payment/request', {}, auth: true);
  }

  static Future<String> checkPaymentStatus(String invoiceId) async {
    final data = await _get('/payment/status/$invoiceId');
    return data['status'];
  }
}
