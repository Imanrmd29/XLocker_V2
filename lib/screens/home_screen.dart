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
              margin: const EdgeInsets.only(top: 20), // Jarak dari atas
              width: double.infinity, // Lebar penuh
              height: MediaQuery.of(context).size.height * 0.2, // Tinggi gambar, bisa disesuaikan
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage('assets/bg_atas.png'), // Path gambar sesuai dengan asset
                  fit: BoxFit.cover,
                ),
                color: Colors.white.withOpacity(0.3), // Opacity gambar
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(0)), // Rounded corners di bawah
              ),
            ),
          ),
          // Background putih dengan rounded corner di bawah
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
            ),
          ),
          // Tombol logout
          Positioned(
            top: 20, // Jarak dari atas
            right: 1, // Jarak dari kanan
            child: IconButton(
              icon: const Icon(Icons.logout),
              color: Colors.white, // Warna ikon
              iconSize: 30, // Ukuran ikon
              onPressed: () {
                // Navigasi ke halaman login
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ),
          // Container untuk ikon profil, teks nama, dan teks tambahan
          Positioned(
            top: 100, // Jarak dari atas, dapat diatur
            left: 30, // Jarak dari kiri
            right: 30, // Jarak dari kanan
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center, // Posisikan di tengah
                children: [
                  // Row untuk ikon profil dan nama
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center, // Pusatkan ikon profil dan nama
                    children: [
                      // Ikon profil dengan kotak rounded
                      Container(
                        width: 70, // Lebar kotak
                        height: 70, // Tinggi kotak
                        decoration: BoxDecoration(
                          color: Colors.white, // Warna kotak
                          borderRadius: BorderRadius.circular(15), // Rounded corners
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
                            size: 40, // Ukuran ikon
                          ),
                        ),
                      ),
                      const SizedBox(width: 10), // Jarak antara ikon profil dan teks nama
                      // Teks nama dengan tata letak yang dapat disesuaikan
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Teks nama
                          Text(
                            'King Salman bin Khaleed', // Ganti dengan nama yang sesuai
                            style: TextStyle(
                              fontSize: 18, // Ukuran teks
                              fontWeight: FontWeight.bold, // Ketebalan teks
                              color: Colors.white, // Warna teks
                            ),
                          ),
                          SizedBox(height: 20), // Jarak antara nama dan teks tambahan
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10,), // Jarak antara profil dan teks tambahan, dapat diatur
                  // Teks tambahan di bawah profil dan nama dengan jarak yang bisa diatur
                  const Text(
                    'Pilih loker yang akan digunakan', // Ganti dengan teks yang diinginkan
                    style: TextStyle(
                      fontSize: 16, // Ukuran teks
                      color: Colors.black, // Warna teks
                    ),
                    textAlign: TextAlign.center, // Pusatkan teks
                  ),
                  // Jarak antara teks dan GridView
                  const SizedBox(height: 5),

                  // Container untuk GridView dengan lebar yang diatur
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0), // Menambahkan padding di sekitar GridView
                    height: MediaQuery.of(context).size.height * 0.7, // Atur tinggi GridView untuk menghindari terpotong
                    child: GridView.builder(
                      // Hapus shrinkWrap jika menggunakan Expanded
                      itemCount: 18,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 5,
                        crossAxisSpacing: 23,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (context, index) {
                        // Menentukan apakah tombol harus dalam keadaan "locked"
                        final isLocked = (index + 1) % 5 == 0 || (index + 1) % 8 == 0 || (index + 1) % 14 == 0;
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 10), // Margin vertikal untuk mengecilkan ukuran box putih
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3), // Sedikit kurang opacity untuk shadow
                                blurRadius: 3, // Blur radius lebih kecil
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Bagian atas tombol
                              Container(
                                height: 51,
                                width: double.infinity, // Mengisi seluruh lebar kontainer
                                decoration: BoxDecoration(
                                  color: isLocked ? const Color(0xFFC20606) : const Color(0xFF0620C2),
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 25, // Ukuran font dikurangi untuk proporsi lebih baik
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              // Bagian bawah tombol dengan status (Lock/Unlock)
                              Container(
                                height: 30,
                                width: double.infinity, // Mengisi seluruh lebar kontainer
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
                                      color: isLocked ? const Color(0xFFC20606) : const Color(0xFF00CC9D),
                                      fontSize: 14, // Ukuran font dikurangi untuk proporsi lebih baik
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
          ),
        ],
      ),
    );
  }
}
