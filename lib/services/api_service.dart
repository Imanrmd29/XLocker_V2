import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xlocker_3/models/telemetry.dart';
import 'package:xlocker_3/models/user.dart';

class ApiService {
  final String baseUrl = "https://thingsboard.cloud/api";

  // StreamController untuk mengirim data telemetry secara real-time
  final StreamController<List<Telemetry>> _telemetryStreamController = StreamController<List<Telemetry>>.broadcast();

  Stream<List<Telemetry>> get telemetryStream => _telemetryStreamController.stream;

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

  Future<void> postRPC(String deviceId, String method, bool params, bool bool) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null) {
      throw Exception("Token tidak ditemukan");
    }

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

  Future<List<Telemetry>> fetchLatestTimeseries() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null) {
      throw Exception("Token tidak ditemukan");
    }

    final response = await http.get(
      Uri.parse('$baseUrl/plugins/telemetry/DEVICE/1295bb70-1332-11ef-ba49-7338e27601c4/values/timeseries'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      List<Telemetry> telemetryData = [];

      data.forEach((key, value) {
        if (value is List) {
          for (var item in value) {
            telemetryData.add(Telemetry.fromJson(item));
          }
        }
      });
      _telemetryStreamController.add(telemetryData);
      return telemetryData;
    } else {
      throw Exception('Gagal mengambil data: ${response.statusCode}');
    }
  }

  // Jangan lupa untuk menutup StreamController saat tidak digunakan lagi
  void dispose() {
    _telemetryStreamController.close();
  }
}
