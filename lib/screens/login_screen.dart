import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  bool _obscureText = true;
  bool _isEmailValid = true;
  bool _isPasswordValid = true;
  bool _isLoading = false;
  late OverlayEntry _overlayEntry;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _showLoadingIndicator() {
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: 0,
        right: 0,
        top: 0,
        bottom: 0,
        child: Container(
          color: Colors.white, // Background gelap dengan transparansi
          child: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
            Image.asset(
              'assets/x_camp_logo.png',
              width: 120,
              height: 120,
            ),
          
            const SizedBox(
              height: 5,
              width: 110,
              child: LinearProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0620C2)),
                backgroundColor: Color.fromARGB(255, 255, 196, 0),
                minHeight: 3.0, // Mengubah ketebalan indikator
              ),
            ),
          ])),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry);
  }

  void _hideLoadingIndicator() {
    _overlayEntry.remove();
  }

  Future<void> _login() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    setState(() {
      _isEmailValid = email.isNotEmpty;
      _isPasswordValid = password.isNotEmpty;
    });

    if (!_isEmailValid || !_isPasswordValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email dan kata sandi tidak boleh kosong.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });
      _showLoadingIndicator();

      final response = await http.post(
        Uri.parse('https://thingsboard.cloud/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', jsonDecode(response.body)['token']);
        await prefs.setBool('isLoggedIn', true);
        // Simpan status login

        // ignore: use_build_context_synchronously
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login gagal! Periksa email dan kata sandi Anda.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() {
          _isEmailValid = false;
          _isPasswordValid = false;
        });
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (_isLoading) {
        _hideLoadingIndicator();
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset('assets/teks_smartlocker.png', height: 70),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Masuk',
                    style: TextStyle(
                      fontSize: 24,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Selamat datang di Aplikasi XLocker',
                    style: TextStyle(fontSize: 16, fontFamily: 'Poppins'),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _emailController,
                    focusNode: _emailFocusNode,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: _isEmailValid ? Colors.grey : Colors.red,
                        ),
                      ),
                      prefixIcon: const Icon(Icons.email),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: _isEmailValid
                              ? const Color(0xFF0620C2)
                              : Colors.red,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: _isEmailValid ? Colors.grey : Colors.red,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    focusNode: _passwordFocusNode,
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      labelText: 'Kata sandi',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: _isPasswordValid ? Colors.grey : Colors.red,
                        ),
                      ),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: _isPasswordValid
                              ? const Color(0xFF0620C2)
                              : Colors.red,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: _isPasswordValid ? Colors.grey : Colors.red,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: const Color(0xFF0620C2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Masuk',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              bottom: 0,
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF0620C2),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: Image.asset(
          'assets/x_camp_logo.png',
          height: 40,
        ),
      ),
    );
  }
}
