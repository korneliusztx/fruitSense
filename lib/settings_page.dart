import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'colors.dart';
import 'login_page.dart';
import 'user_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;

  bool _isEditing = false;
  bool _isLoading = true;
  bool _isSaving = false;

  File? _selectedImage;
  bool _imageDeleted = false; // Flag untuk track jika image dihapus
  Map<String, dynamic>? _currentUserData;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _loadUserData();
  }

  // Load data user yang sedang login
  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    try {
      final userData = await UserService.getCurrentUser();

      if (userData != null) {
        setState(() {
          _currentUserData = userData;
          _usernameController.text = userData['username'] ?? '';
          _emailController.text = userData['email'] ?? '';
          _imageDeleted = false; // Reset flag
        });

        final profileImage = await UserService.getProfileImage();
        if (profileImage != null) {
          setState(() {
            _selectedImage = profileImage;
          });
        }

        debugPrint('✅ User data loaded: ${userData['username']}');
      } else {
        debugPrint('⚠️ No user data found');
      }
    } catch (e) {
      debugPrint('❌ Error loading user data: $e');
      _showSnackBar('Gagal memuat data pengguna', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Save perubahan profil
  Future<void> _saveProfile() async {
    if (_currentUserData == null) return;

    // Validasi
    if (_usernameController.text.trim().isEmpty) {
      _showSnackBar('Username tidak boleh kosong', isError: true);
      return;
    }

    if (_emailController.text.trim().isEmpty) {
      _showSnackBar('Email tidak boleh kosong', isError: true);
      return;
    }

    if (!_emailController.text.contains('@')) {
      _showSnackBar('Format email tidak valid', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Jika image dihapus, hapus dari storage
      if (_imageDeleted) {
        await UserService.deleteProfileImage();
        debugPrint('🗑️ Profile image deleted');
      }

      // Dapatkan userId (cek di user_id atau id)
      final userId = _currentUserData!['user_id'] ?? _currentUserData!['id'];

      // Update profil (termasuk update ke JSON AuthService)
      final success = await UserService.updateUserProfile(
        userId: userId,
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        profileImage: (_imageDeleted || _selectedImage == null) ? null : _selectedImage,
      );

      if (success) {
        // Reload data terbaru dari JSON
        await _loadUserData();

        setState(() {
          _isEditing = false;
        });

        _showSnackBar('✅ Profil berhasil diperbarui!', isError: false);
        debugPrint('✅ Profile updated in JSON and session');
      } else {
        _showSnackBar('❌ Gagal memperbarui profil', isError: true);
      }
    } catch (e) {
      debugPrint('❌ Error saving profile: $e');
      _showSnackBar('Terjadi kesalahan saat menyimpan', isError: true);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _imageDeleted = false; // Reset flag karena ada gambar baru
      });

      _showSnackBar('Foto profil dipilih. Klik Simpan untuk menyimpan perubahan.', isError: false);
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Ganti Foto Profil",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildImageSourceOption(
                    icon: Icons.camera_alt,
                    label: "Kamera",
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                  _buildImageSourceOption(
                    icon: Icons.photo_library,
                    label: "Galeri",
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                  if (_selectedImage != null && !_imageDeleted)
                    _buildImageSourceOption(
                      icon: Icons.delete_outline,
                      label: "Hapus",
                      color: Colors.red,
                      onTap: () {
                        Navigator.pop(context);
                        setState(() {
                          _selectedImage = null;
                          _imageDeleted = true;
                        });
                        _showSnackBar('Foto profil akan dihapus. Klik Simpan untuk konfirmasi.', isError: false);
                      },
                    ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: color?.withOpacity(0.1) ?? Colors.grey[200],
            child: Icon(icon, color: color ?? AppColors.primary, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontWeight: FontWeight.w500, color: color)),
        ],
      ),
    );
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? Colors.red : AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.only(bottom: 12, left: 20, right: 20),
      ),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Apakah Anda yakin ingin keluar?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await UserService.logout();

              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                      (route) => false,
                );
              }
            },
            child: const Text(
              "Logout",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Loading state
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Error state
    if (_currentUserData == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              const Text(
                'Tidak dapat memuat data pengguna',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadUserData,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Main content
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_isEditing)
            TextButton(
              onPressed: () {
                setState(() {
                  _isEditing = false;
                  _loadUserData();
                });
              },
              child: const Text(
                'Batal',
                style: TextStyle(color: Colors.grey),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),

              // FOTO PROFIL
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 90,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: (_selectedImage != null && !_imageDeleted)
                        ? FileImage(_selectedImage!) as ImageProvider
                        : null,
                    child: (_selectedImage == null || _imageDeleted)
                        ? _buildDefaultAvatar()
                        : null,
                  ),
                  if (_isEditing)
                    GestureDetector(
                      onTap: () => _showImageSourceActionSheet(context),
                      child: Container(
                        height: 35,
                        width: 35,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Role badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary, width: 1),
                ),
                child: Text(
                  _currentUserData!['role'] == 'farmer' ? '🌾 Farmer' : '👤 User',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Username Field
              _buildEditableField(
                label: 'Username',
                controller: _usernameController,
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 20),

              // Email Field
              _buildEditableField(
                label: 'Email',
                controller: _emailController,
                icon: Icons.mail_outline,
              ),
              const SizedBox(height: 16),

              // Tombol Edit/Simpan
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 150,
                  child: ElevatedButton(
                    onPressed: _isSaving
                        ? null
                        : () {
                      if (_isEditing) {
                        _saveProfile();
                      } else {
                        setState(() => _isEditing = true);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isEditing ? AppColors.primary : Colors.grey[200],
                      foregroundColor: _isEditing ? Colors.white : AppColors.primary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      disabledBackgroundColor: Colors.grey[300],
                    ),
                    child: _isSaving
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : Text(
                      _isEditing ? "Simpan" : "Edit Profil",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Tombol Logout
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _handleLogout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[50],
                    foregroundColor: Colors.red,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Colors.red, width: 1),
                    ),
                  ),
                  icon: const Icon(Icons.logout),
                  label: const Text(
                    "Log Out",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textLight,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: _isEditing ? Colors.white : AppColors.borderLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isEditing ? AppColors.primary : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.textMutedLight),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  enabled: _isEditing,
                  style: const TextStyle(color: AppColors.textLight, fontSize: 16),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar() {
    String initial = '';

    if (_currentUserData != null) {
      final username = _currentUserData!['username'] ?? '';
      if (username.isNotEmpty) {
        initial = username[0].toUpperCase();
      }
    }

    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.7),
          ],
        ),
      ),
      child: Center(
        child: Text(
          initial.isNotEmpty ? initial : '?',
          style: const TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}