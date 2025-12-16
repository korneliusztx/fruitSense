import 'package:flutter/material.dart';
import 'colors.dart';
import 'main.dart'; // Impor main untuk navigasi ke MainPage

class PasswordPage extends StatefulWidget {
  const PasswordPage({super.key});

  @override
  State<PasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              // LOGO FRUITSENSE (Diperbarui)
              Image.asset(
                'assets/images/logo fruitsense_ijo.png',
                width: 250,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 80),

              // Form Password
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'Password',
                    style: const TextStyle(
                      color: Color(0xFF1E3A2F),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              TextField(
                obscureText: _obscureText,
                decoration: InputDecoration(
                  hintText: 'Input your password here',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFFE0E0E0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 200), // Spasi besar agar tombol Next ada di bawah

              // Tombol Next (Masuk ke Home)
              TextButton(
                onPressed: () {
                  // Navigasi ke MainPage dan menghapus history navigasi sebelumnya
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const MainPage()),
                        (Route<dynamic> route) => false,
                  );
                },
                child: const Text(
                  'Next',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}