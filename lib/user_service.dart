import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'auth_services.dart';

class UserService {
  static const String _currentUserKey = 'current_user';
  static const String _profileImagePrefix = 'profile_image_';

  // Singleton untuk AuthService
  static final AuthService _authService = AuthService();

  // Simpan current user yang sedang login
  static Future<void> saveCurrentUser(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserKey, jsonEncode(userData));
    debugPrint('✅ Current user saved: ${userData['username']}');
  }

  // Ambil data user yang sedang login
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userString = prefs.getString(_currentUserKey);

      if (userString != null) {
        return jsonDecode(userString);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting current user: $e');
      return null;
    }
  }

  // Update profil user (nama, email, foto) - DENGAN SINKRONISASI KE JSON
  static Future<bool> updateUserProfile({
    required String userId,
    String? username,
    String? email,
    File? profileImage,
  }) async {
    try {
      // 1. Ambil current user untuk mengetahui role
      final currentUserData = await getCurrentUser();
      if (currentUserData == null) {
        debugPrint('❌ No current user found');
        return false;
      }

      // Tentukan apakah user adalah farmer atau bukan
      final isFarmer = currentUserData['role'] == 'farmer';
      debugPrint('📝 Updating ${isFarmer ? "farmer" : "user"} profile...');

      // 2. Update data di AuthService JSON file
      final Map<String, dynamic> updatedData = {};
      if (username != null) updatedData['username'] = username;
      if (email != null) updatedData['email'] = email;

      final updateSuccess = await _authService.updateUser(
        userId: userId,
        updatedData: updatedData,
        isFarmer: isFarmer,
      );

      if (!updateSuccess) {
        debugPrint('❌ Failed to update user in JSON');
        return false;
      }

      debugPrint('✅ User updated in JSON file');

      // 3. Ambil data terbaru dari JSON untuk sinkronisasi
      final users = await _authService.getAllUsers(isFarmer);
      final updatedUser = users.firstWhere(
            (u) => u['id'] == userId,
        orElse: () => {},
      );

      if (updatedUser.isEmpty) {
        debugPrint('❌ Could not find updated user');
        return false;
      }

      // 4. Tambahkan role ke updated user (karena tidak disimpan di JSON)
      updatedUser['role'] = isFarmer ? 'farmer' : 'user';
      updatedUser['user_id'] = userId;

      // 5. Simpan profile image jika ada
      if (profileImage != null) {
        final imagePath = await _saveProfileImage(userId, profileImage);
        updatedUser['profile_image'] = imagePath;
      } else {
        // Pertahankan profile image yang sudah ada
        if (currentUserData['profile_image'] != null) {
          updatedUser['profile_image'] = currentUserData['profile_image'];
        }
      }

      // 6. Update current user session dengan data terbaru
      await saveCurrentUser(updatedUser);

      debugPrint('✅ User profile updated successfully in both JSON and session');
      return true;
    } catch (e) {
      debugPrint('❌ Error updating user profile: $e');
      return false;
    }
  }

  // Simpan foto profil ke storage lokal
  static Future<String> _saveProfileImage(String userId, File imageFile) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final profileImagesDir = Directory('${directory.path}/profile_images');

      if (!await profileImagesDir.exists()) {
        await profileImagesDir.create(recursive: true);
      }

      final String filename = 'profile_$userId.jpg';
      final String imagePath = '${profileImagesDir.path}/$filename';

      // Hapus foto lama jika ada
      final oldFile = File(imagePath);
      if (await oldFile.exists()) {
        await oldFile.delete();
      }

      // Copy file baru
      final savedImage = await imageFile.copy(imagePath);
      debugPrint('✅ Profile image saved to: $imagePath');

      return savedImage.path;
    } catch (e) {
      debugPrint('❌ Error saving profile image: $e');
      rethrow;
    }
  }

  // Delete profile image
  static Future<void> deleteProfileImage() async {
    try {
      final currentUser = await getCurrentUser();
      if (currentUser == null) return;

      final imagePath = currentUser['profile_image'];
      if (imagePath != null && imagePath.isNotEmpty) {
        final file = File(imagePath);
        if (await file.exists()) {
          await file.delete();
          debugPrint('✅ Profile image deleted');
        }
      }

      // Update user data - hapus path image
      currentUser['profile_image'] = null;
      await saveCurrentUser(currentUser);
    } catch (e) {
      debugPrint('❌ Error deleting profile image: $e');
    }
  }

  // Get profile image
  static Future<File?> getProfileImage() async {
    try {
      final userData = await getCurrentUser();
      if (userData == null) return null;

      final imagePath = userData['profile_image'];
      if (imagePath != null && imagePath.isNotEmpty) {
        final file = File(imagePath);
        if (await file.exists()) {
          return file;
        }
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting profile image: $e');
      return null;
    }
  }

  // Logout - hapus current user
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
    debugPrint('✅ User logged out');
  }

  // Cek apakah user sudah login
  static Future<bool> isLoggedIn() async {
    final user = await getCurrentUser();
    return user != null;
  }
}