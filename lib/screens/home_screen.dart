import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xlocker_3/services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService apiService = ApiService();
  List<bool> _isClicked = List<bool>.filled(18, false); // Menyimpan status klik untuk setiap item

  void _showLoadingIndicator(BuildContext context) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: 0,
        right: 0,
        top: 0,
        bottom: 0,
        child: Container(
          color: Colors.white,
          child: const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF0620C2),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 4), () {
      overlayEntry.remove();
    });
  }

  Future<void> _handleLogout(BuildContext context) async {
    _showLoadingIndicator(context);

    await Future.delayed(const Duration(seconds: 1));

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');

    Future.delayed(const Duration(milliseconds: 100), () {
      Navigator.pushReplacementNamed(context, '/login');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logout Berhasil', textAlign: TextAlign.center),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          width: 180,
        ),
      );
    });
  }

  Future<void> _handleGridItemTap(int index) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      if (token != null) {
        await apiService.postRPC(
          token,
          'deviceId', // Ganti dengan deviceId yang benar jika ada
          'setRelay${index + 1}',
          true,
        );

        setState(() {
          _isClicked[index] = !_isClicked[index]; // Toggle status klik
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                _isClicked[index] ? 'Loker ${index + 1} Dibuka' : 'Loker ${index + 1} Ditutup'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim RPC: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF0620C2),
            ),
            height: MediaQuery.of(context).size.height,
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.only(top: 32),
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.15,
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage('assets/bg_atas.png'),
                  fit: BoxFit.cover,
                ),
                color: Colors.white.withOpacity(0.3),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.84,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
            ),
          ),
          Positioned(
            top: 30,
            right: 5,
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.menu, color: Colors.white, size: 30),
              onSelected: (value) {
                if (value == 'logout') {
                  _handleLogout(context);
                }
              },
              itemBuilder: (context) => [
                _buildPopupMenuItem('logout', Icons.logout),
              ],
            ),
          ),
          Positioned(
            top: 52,
            left: 38,
            right: 30,
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0620C2).withOpacity(0.9),
                        blurRadius: 2,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.person,
                      color: Colors.blue,
                      size: 30,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'King Salman bin Khaleed',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 0),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.18,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Pilih nomor loker yang akan digunakan',
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.black,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  height: MediaQuery.of(context).size.height * 0.80,
                  child: GridView.builder(
                    itemCount: 18,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 35,
                      childAspectRatio: 1,
                    ),
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => _handleGridItemTap(index),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 52,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: _isClicked[index]
                                    ? const Color(0xFFC20606) // Warna merah jika diklik
                                    : const Color(0xFF0620C2), // Warna biru jika tidak
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              height: 30,
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE1E1E1),
                                borderRadius: BorderRadius.vertical(
                                  bottom: Radius.circular(12),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  _isClicked[index] ? 'Lock' : 'Unlock',
                                  style: TextStyle(
                                    color: _isClicked[index]
                                        ? const Color(0xFFC20606)
                                        : const Color(0xFF00CC9D),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

PopupMenuItem<String> _buildPopupMenuItem(String s, IconData icon) {
  return PopupMenuItem<String>(
    value: s,
    child: Row(
      children: [
        Icon(icon),
        const SizedBox(width: 8),
        Text(s),
      ],
    ),
  );
}
