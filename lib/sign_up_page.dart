import 'package:flutter/material.dart';
import 'package:fruitsense_app_v2/auth_services.dart';
import 'colors.dart';
import 'login_page.dart';
import 'main.dart';
import 'farmer_main_page.dart';

class SignUpPage extends StatefulWidget {
  final bool isUserMode; // Tambahkan parameter ini agar konsisten dengan LoginPage

  const SignUpPage({super.key, this.isUserMode = true});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  late bool _isUser; // State untuk toggle (True = User, False = Farmer)

  // Controllers untuk form
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Loading state
  bool _isLoading = false;

  // Auth service
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _isUser = widget.isUserMode; // Inisialisasi dari parameter
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Validasi form
  String? _validateForm() {
    // Email
    if (_emailController.text.trim().isEmpty) {
      return 'Email tidak boleh kosong';
    }
    if (!_emailController.text.contains('@') || !_emailController.text.contains('.')) {
      return 'Format email tidak valid';
    }

    // Username
    if (_usernameController.text.trim().isEmpty) {
      return 'Username tidak boleh kosong';
    }
    if (_usernameController.text.trim().length < 4) {
      return 'Username minimal 4 karakter';
    }

    // Password
    if (_passwordController.text.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (_passwordController.text.length < 6) {
      return 'Password minimal 6 karakter';
    }

    // Confirm password
    if (_confirmPasswordController.text.isEmpty) {
      return 'Konfirmasi password tidak boleh kosong';
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      return 'Password tidak cocok';
    }

    return null; // Valid
  }

  // Handle register
  Future<void> _handleRegister() async {
    // Validasi
    final error = _validateForm();
    if (error != null) {
      _showSnackBar(error, isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Generate nama lengkap dari username (bisa disesuaikan)
      final fullName = _usernameController.text.trim();

      // Generate phone number default (bisa ditambahkan field jika perlu)
      final phone = '08${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

      // Panggil register service
      final result = await _authService.register(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: fullName,
        phone: phone,
        isFarmer: !_isUser,
        farmName: _isUser ? null : 'Kebun ${fullName}',
        farmLocation: _isUser ? null : 'Indonesia',
      );

      setState(() => _isLoading = false);

      if (result.success) {
        // Registrasi berhasil
        _showSnackBar(result.message, isError: false);

        // Tunggu sebentar agar snackbar terlihat
        await Future.delayed(const Duration(milliseconds: 500));

        // Navigate berdasarkan role dengan success dialog
        if (!mounted) return;

        if (_isUser) {
          // MASUK KE MAIN PAGE DENGAN DIALOG SAMBUTAN
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => MainPage(
                showSuccessDialog: true,
                userData: result.userData,
              ),
            ),
                (route) => false,
          );
        } else {
          // MASUK KE FARMER MAIN PAGE DENGAN DIALOG SAMBUTAN
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => FarmerMainPage(
                showSuccessDialog: true,
                userData: result.userData,
              ),
            ),
                (route) => false,
          );
        }
      } else {
        // Registrasi gagal
        _showSnackBar(result.message, isError: true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Terjadi kesalahan: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : AppColors.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // LOGO
              Image.asset(
                'assets/images/logo fruitsense_ijo.png',
                width: 180,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 30),

              // --- TOGGLE SWITCH (Pilihan User / Farmer) ---
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    // TOMBOL USER
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isUser = true),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _isUser ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'User',
                            style: TextStyle(
                              color: _isUser ? Colors.white : Colors.grey[600],
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // TOMBOL FARMER
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isUser = false),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: !_isUser ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (!_isUser) const Icon(Icons.agriculture, color: Colors.white, size: 18),
                              if (!_isUser) const SizedBox(width: 8),
                              Text(
                                'Farmer',
                                style: TextStyle(
                                  color: !_isUser ? Colors.white : Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // --- REGISTER FORM ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // JUDUL DINAMIS
                    Center(
                      child: Column(
                        children: [
                          Text(
                            _isUser ? 'User Register' : 'Farmer Register',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Your guide to freshness awaits.',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 1. Email
                    const Text("Email", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'example@gmail.com',
                        hintStyle: const TextStyle(color: Colors.grey),
                        prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
                        filled: true,
                        fillColor: Colors.grey[300],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 2. Username
                    const Text("Username", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        hintText: 'Input your username here',
                        hintStyle: const TextStyle(color: Colors.grey),
                        prefixIcon: const Icon(Icons.person_outline, color: Colors.grey),
                        filled: true,
                        fillColor: Colors.grey[300],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 3. Password
                    const Text("Create Password", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Input your new password here',
                        hintStyle: const TextStyle(color: Colors.grey),
                        prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                        filled: true,
                        fillColor: Colors.grey[300],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 4. Re-Password
                    const Text("Re-enter Password", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Input again your password here',
                        hintStyle: const TextStyle(color: Colors.grey),
                        prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                        filled: true,
                        fillColor: Colors.grey[300],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // BUTTON REGISTER
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          disabledBackgroundColor: Colors.grey[400],
                        ),
                        child: _isLoading
                            ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                            : const Text(
                          'Register',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Link to Login
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Already have an account? ",
                          style: TextStyle(fontSize: 12),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginPage()),
                            );
                          },
                          child: const Text(
                            "Login",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // --- SOCIAL LOGIN (Optional, bisa dihapus jika tidak diperlukan di register) ---
              const Text("or", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialIcon('assets/images/google.png', Colors.red, 'G'),
                  const SizedBox(width: 20),
                  _buildSocialIcon('assets/images/facebook.png', Colors.blue, 'f'),
                  const SizedBox(width: 20),
                  _buildSocialIcon(null, Colors.black, null, iconData: Icons.phone),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialIcon(String? assetName, Color color, String? letter, {IconData? iconData}) {
    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: iconData != null
          ? Icon(iconData, color: color, size: 20)
          : (assetName != null
          ? Image.asset(assetName,
          width: 24,
          errorBuilder: (c, e, s) => Text(letter!,
              style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)))
          : Text(letter ?? '',
          style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold))),
    );
  }
}