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
            } else {
              setState(() {
                _isRed[i] = false;
                _isClicked[i] = false; // Nonaktifkan klik jika nilainya 1
              });
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tidak terhubung dengan Database: $e'),
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

        // Tampilkan AlertDialog
        _showTimedAlertDialog(context, '${index + 1}');
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

  void _showTimedAlertDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Menutup dialog setelah 3 detik
        Future.delayed(const Duration(seconds: 3), () {
          Navigator.of(context).pop(true);
        });

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0), // Sudut melengkung
          ),
          title: const Center(
            child: Text(
              'Nomor loker yang dipilih',
              style: TextStyle(
                fontSize: 18, // Ukuran font untuk judul
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          content: Container(
            width: double.maxFinite,
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors
                  .grey[300], // Warna latar belakang abu-abu untuk kotak nomor
              borderRadius: BorderRadius.circular(
                  15.0), // Sudut melengkung pada kotak nomor
            ),
            constraints: const BoxConstraints(
              maxWidth: 150, // Lebar maksimal box
              maxHeight: 120, // Tinggi maksimal box
            ),
            child: Center(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 50, // Ukuran font terbesar untuk nomor loker
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF0620C2), // Warna pertama
                      Color(0xFF030F5C), // Warna kedua
                    ],
                  ),
                ),
                height: MediaQuery.of(context).size.height,
              ),
              Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 1.5), // Jarak dari atas
                    child: Opacity(
                      opacity: 0.3, // Setel opasitas di sini, bisa disesuaikan
                      child: Image.asset(
                        'assets/x_camp_logo.png', // Ganti dengan path gambar Anda
                        height: 135.0, // Atur tinggi gambar sesuai keinginan
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  // Tambahkan widget lain di sini jika diperlukan
                ],
              ),
            ],
          ),
          Stack(
            children: [
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.85,
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
                top: 105, // Adjust as needed
                left: 130, // Adjust as needed
                // right: 20, // Adjust as needed
                child: Container(
                  alignment: Alignment.center,
                  child: const Text(
                    'King Salman bin Khaleed',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors
                          .white, // Changed to black for visibility on white background
                    ),
                  ),
                ),
              ),
            ],
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
            top: 90,
            left: 65,
            child: Row(
              children: [
                Container(
                  width: 57,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF0620C2), // Warna stroke (border)
                      width: 2, // Ketebalan stroke (border)
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        blurRadius: 2,
                        offset: const Offset(0, 5),
                      ),
                    ],
                    image: const DecorationImage(
                      image: NetworkImage(
                        'https://your-image-url.com', // Ganti dengan URL image profile
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
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
