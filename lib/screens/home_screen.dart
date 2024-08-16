import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background biru
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF0620C2), // Warna biru background
            ),
            height: MediaQuery.of(context).size.height,
          ),
          // Gambar di dalam background biru, rata kanan kiri, top center
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.only(top: 32), // Jarak dari atas
              width: double.infinity, // Lebar penuh
              height: MediaQuery.of(context).size.height * 0.15, // Tinggi gambar, bisa disesuaikan
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage('assets/bg_atas.png'), // Path gambar sesuai dengan asset
                  fit: BoxFit.cover,
                ),
                color: Colors.white.withOpacity(0.3), // Opacity gambar
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(0), // Rounded corners di bawah
                ),
              ),
            ),
          ),
          // Background putih dengan rounded corner di bawah
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
          // Tombol menu
          Positioned(
            top: 30, // Jarak dari atas
            right: 5, // Jarak dari kanan
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.menu, color: Colors.white, size: 30),
              onSelected: (value) {
                if (value == 'logout') {
                  // Navigasi ke halaman login
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
              itemBuilder: (context) => [
                _buildPopupMenuItem('logout', Icons.logout),
              ],
            ),
          ),

          //           Positioned(
          //   top: 20, // Jarak dari atas
          //   right: 1, // Jarak dari kanan
          //   child: IconButton(
          //     icon: const Icon(Icons.logout),
          //     color: Colors.white, // Warna ikon
          //     iconSize: 30, // Ukuran ikon
          //     onPressed: () {
          //       // Navigasi ke halaman login
          //       Navigator.pushReplacementNamed(context, '/login');
          //     },
          //   ),
          // ),
          // Profil dan nama
          Positioned(
            top: 52, // Jarak dari atas, dapat diatur
            left: 38, // Jarak dari kiri
            right: 30,
            child: Row(
              children: [
                // Ikon profil dengan kotak rounded
                Container(
                  width: 50, // Lebar kotak
                  height: 50, // Tinggi kotak
                  decoration: BoxDecoration(
                    color: Colors.white, // Warna kotak
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0620C2).withOpacity(0.9),
                        blurRadius: 2,
                        offset: const Offset(0, 2), // Posisi bayangan
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.person, // Ikon profil
                      color: Colors.blue, // Warna ikon
                      size: 30, // Ukuran ikon
                    ),
                  ),
                ),
                const SizedBox(
                    width: 10), // Jarak antara ikon profil dan teks nama
                // Teks nama dengan tata letak yang dapat disesuaikan
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Teks nama
                    Text(
                      'King Salman bin Khaleed', // Ganti dengan nama yang sesuai
                      style: TextStyle(
                        fontSize: 17, // Ukuran teks
                        fontWeight: FontWeight.bold, // Ketebalan teks
                        color: Colors.white, // Warna teks
                      ),
                    ),
                    SizedBox(height: 0), // Jarak antara nama dan teks tambahan
                  ],
                ),
              ],
            ),
          ),
          // Teks tengah dan GridView
          Positioned(
            top: MediaQuery.of(context).size.height * 0.18, // Sesuaikan posisi
            left: 0,
            right: 0,
            child: Column(
              children: [
                const Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Pilih nomor loker yang akan digunakan',
                    style: TextStyle(
                      fontSize: 17, // Ukuran teks // Ketebalan teks
                      color: Colors.black, // Warna teks
                    ),
                  ),
                ), 
               // Jarak antara teks dan GridView
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  height: MediaQuery.of(context).size.height * 0.80, // Sesuaikan tinggi
                  child: GridView.builder(
                    itemCount: 18,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 35,
                      childAspectRatio: 1,
                    ),
                    itemBuilder: (context, index) {
                      final isLocked = (index + 1) % 5 == 0 ||
                          (index + 1) % 8 == 0 ||
                          (index + 1) % 14 == 0;
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              blurRadius: 3,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 52,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: isLocked
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
                                color: Color(0xFFE1E1E1),
                                borderRadius: BorderRadius.vertical(
                                  bottom: Radius.circular(12),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  isLocked ? 'Lock' : 'Unlock',
                                  style: TextStyle(
                                    color: isLocked
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
          ),
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
