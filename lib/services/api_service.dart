import 'dart:convert';
import 'dart:ffi';
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

  Future<void> postRPC(
    String token,
    String deviceId,
    String method,
    bool params,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/rpc/oneway/1295bb70-1332-11ef-ba49-7338e27601c4'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'method': method,
        'params': params,
      }),
    );

    if (response.statusCode == 200) {
      print('RPC command berhasil dikirim');
    } else {
      throw Exception('Gagal mengirim RPC command: ${response.body}');
    }
  }
}

  // Future<User?> postRPC(
  //     String token, String deviceId, Bool params, String method) async {
  //   final response = await http.post(
  //     Uri.parse('$baseUrl/rpc/oneway/1295bb70-1332-11ef-ba49-7338e27601c4'),
  //     headers: {'Authorization': 'Bearer $token'},
  //   );

  //   if (response.statusCode == 200) {
  //     return User.fromJson(jsonDecode(response.body));
  //   } else {
  //     throw Exception('Failed to Post RPC');
  //   }
  // }

