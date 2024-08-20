import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xlocker_3/providers/auth_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Mengambil status login dari SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: XLocker(isLoggedIn: isLoggedIn),
    ),
  );
}

class XLocker extends StatelessWidget {
  final bool isLoggedIn;

  const XLocker({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'XLocker App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      initialRoute: isLoggedIn ? '/home' : '/',
      routes: {
        '/' : (context) => const SplashScreen(),
        '/login' : (context) => const LoginScreen(),
        '/home' : (context) => HomeScreen(),
      },
      // Handler untuk mengganti status login saat logout
      onGenerateRoute: (settings) {
        if (settings.name == '/logout') {
          // Clear login status dan navigasi ke layar login
          _handleLogout(context);
          return MaterialPageRoute(builder: (_) => const LoginScreen());
        }
        return null;
      },
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');

    // Navigasi ke layar login setelah logout
    // ignore: use_build_context_synchronously
    Navigator.of(context).pushReplacementNamed('/login');
  }
}
