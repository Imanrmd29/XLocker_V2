import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    // Menunggu beberapa detik untuk menampilkan splash screen
    Timer(const Duration(seconds: 2), () {
      // Arahkan ke home jika sudah login, jika tidak, arahkan ke login
      Navigator.pushReplacementNamed(
        context,
        isLoggedIn ? '/home' : '/login',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Gambar logo dengan ukuran lebih besar
            Image.asset('assets/x_camp_splashscreen.png', height: 140),
          ],
        ),
      ),
    );
  }
}
