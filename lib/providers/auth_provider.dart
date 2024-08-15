import 'package:flutter/material.dart';
import 'package:xlocker_3/models/user.dart';
import 'package:xlocker_3/services/api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;

  User? get user => _user;

  Future<void> login(String username, String password) async {
    _user = await ApiService().login(username, password);
    notifyListeners();
  }
}
