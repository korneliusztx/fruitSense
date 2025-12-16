import 'dart:async';
import 'package:flutter/material.dart';
import 'colors.dart';
import 'login_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Gambar Logo dengan nama baru
            Image.asset(
              'assets/images/logo_white.png', // <--- NAMA FILE BARU (Tanpa Spasi)
              width: 180,
              errorBuilder: (context, error, stackTrace) {
                // Jika gambar error, akan muncul Icon Apple + Teks
                return const Column(
                  children: [
                    Icon(Icons.local_florist, size: 80, color: Colors.white),
                    SizedBox(height: 10),
                    Text(
                        "Gambar Tidak Ditemukan",
                        style: TextStyle(color: Colors.white)
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 20),

            // Indikator Loading
            const CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}