import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xlocker_3/models/user.dart';

class ApiService {
  final String baseUrl = "https://thingsboard.cloud/api";

  Future<User?> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to login');
    }
  }
}