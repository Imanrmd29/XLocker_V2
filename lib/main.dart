import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xlocker_3/providers/auth_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const XLocker(),
    ),
  );
}

class XLocker extends StatelessWidget {
  const XLocker({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'XLocker App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        fontFamily: 'Poppins'
      ),
      initialRoute: '/',
      routes: {
        '/' : (context) => const SplashScreen(),
        '/login' : (context) => const LoginScreen(),
        '/home' : (context) => const HomeScreen(),
      },
    );
  }
}
