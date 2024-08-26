import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xlocker_3/services/api_service.dart';
import 'package:xlocker_3/models/telemetry.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService apiService = ApiService();
  final List<bool> _isClicked = List<bool>.filled(18, false);
  final List<bool> _isRed =
      List<bool>.filled(18, false); // Menyimpan status klik untuk setiap item
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startFetchingData();
  }

  @override
  void dispose() {
    _timer?.cancel(); // Batalkan timer saat widget tidak lagi digunakan
    super.dispose();
  }

  void _startFetchingData() {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _fetchAndUpdateGridStatus();
    });
  }

  Future<void> _fetchAndUpdateGridStatus() async {
    try {
      List<Telemetry> telemetryData = await apiService.fetchLatestTimeseries();

      if (mounted) {
        for (int i = 0; i < telemetryData.length; i++) {
          if (i < _isRed.length) {
            if (telemetryData[i].value == "1") {
              setState(() {
                _isRed[i] = true;
                _isClicked[i] = true; // Nonaktifkan klik jika nilainya 1
              });
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data telemetri: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

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
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/x_camp_logo.png', // Ganti dengan path gambar Anda
                  width: 100,
                  height: 100,
                ),
                const SizedBox(
                  height: 5,
                  width: 110,
                  child: LinearProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF0620C2)),
                    backgroundColor: Color.fromARGB(255, 255, 196, 0),
                    minHeight: 3.0, // Mengubah ketebalan indikator
                  ),
                ),
              ],
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
    if (_isRed[index]) return; // Jangan izinkan klik jika sudah merah

    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      if (token != null) {
        // Mengambil status klik saat ini
        bool currentStatus = _isClicked[index];

        // Mengirimkan RPC dengan status yang berlawanan dari status saat ini
        await apiService.postRPC(
          token,
          'deviceId', // Ganti dengan deviceId yang benar jika ada
          'setRelay${index + 1}',
          !currentStatus, // Toggle status: jika saat ini true, kirim false, dan sebaliknya
        );

        // Memperbarui status klik
        setState(() {
          _isClicked[index] = true; // Tandai sudah diklik
          _isRed[index] = true; // Ubah menjadi merah
        });

        // Tampilkan pesan sukses berdasarkan status terkini
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Loker ${index + 1} Dibuka', textAlign: TextAlign.center),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            elevation: 10,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengirim RPC: $e', textAlign: TextAlign.center),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
          elevation: 10,
        ),
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
              margin: const EdgeInsets.only(top: 25),
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
                        onTap: _isRed[index] || _isClicked[index]
                            ? null
                            : () => _handleGridItemTap(index),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 52,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: _isClicked[index]
                                    ? const Color(0xFFC20606)
                                    : const Color(0xFF0620C2),
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
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color.fromARGB(52, 0, 0, 0),
                                    offset: Offset.zero,
                                    blurRadius: 0.5,
                                    spreadRadius: 0.5,
                                  ),
                                ],
                                borderRadius: BorderRadius.vertical(
                                  bottom: Radius.circular(12),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  _isClicked[index] ? 'Terisi' : 'Kosong',
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
