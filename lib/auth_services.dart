import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Service untuk mengelola autentikasi user dengan penyimpanan JSON lokal
class AuthService {
  static const String _usersFileName = 'users.json';
  static const String _farmersFileName = 'farmers.json';

  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  /// Get path untuk menyimpan file JSON
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  /// Get file untuk users
  Future<File> get _usersFile async {
    final path = await _localPath;
    return File('$path/$_usersFileName');
  }

  /// Get file untuk farmers
  Future<File> get _farmersFile async {
    final path = await _localPath;
    return File('$path/$_farmersFileName');
  }

  /// Load users dari JSON file
  Future<List<Map<String, dynamic>>> _loadUsers(bool isFarmer) async {
    try {
      final file = isFarmer ? await _farmersFile : await _usersFile;

      // Jika file tidak ada, buat dengan data default
      if (!await file.exists()) {
        await _createDefaultData(isFarmer);
      }

      final contents = await file.readAsString();
      final List<dynamic> jsonData = jsonDecode(contents);
      return jsonData.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error loading users: $e');
      return [];
    }
  }

  /// Save users ke JSON file
  Future<void> _saveUsers(List<Map<String, dynamic>> users, bool isFarmer) async {
    try {
      final file = isFarmer ? await _farmersFile : await _usersFile;
      final jsonString = jsonEncode(users);
      await file.writeAsString(jsonString);
    } catch (e) {
      print('Error saving users: $e');
    }
  }

  /// Create default data untuk pertama kali
  Future<void> _createDefaultData(bool isFarmer) async {
    final defaultUsers = [
      {
        'id': '1',
        'username': 'user1',
        'email': 'user1@fruitsense.com',
        'password': 'password123',
        'fullName': 'John Doe',
        'phone': '081234567890',
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'id': '2',
        'username': 'testuser',
        'email': 'test@fruitsense.com',
        'password': 'test123',
        'fullName': 'Test User',
        'phone': '081234567891',
        'createdAt': DateTime.now().toIso8601String(),
      },
    ];

    final defaultFarmers = [
      {
        'id': '1',
        'username': 'farmer1',
        'email': 'farmer1@fruitsense.com',
        'password': 'farmer123',
        'fullName': 'Budi Santoso',
        'phone': '081234567892',
        'farmName': 'Kebun Apel Malang',
        'farmLocation': 'Malang, Jawa Timur',
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'id': '2',
        'username': 'petani1',
        'email': 'petani@fruitsense.com',
        'password': 'petani123',
        'fullName': 'Siti Rahayu',
        'phone': '081234567893',
        'farmName': 'Kebun Jeruk Pontianak',
        'farmLocation': 'Pontianak, Kalimantan Barat',
        'createdAt': DateTime.now().toIso8601String(),
      },
    ];

    await _saveUsers(isFarmer ? defaultFarmers : defaultUsers, isFarmer);
  }

  /// Login function
  Future<LoginResult> login({
    required String username,
    required String password,
    required bool isFarmer,
  }) async {
    try {
      final users = await _loadUsers(isFarmer);

      // Cari user dengan username atau email yang cocok
      final user = users.firstWhere(
            (u) =>
        (u['username'] == username || u['email'] == username) &&
            u['password'] == password,
        orElse: () => {},
      );

      if (user.isEmpty) {
        return LoginResult(
          success: false,
          message: 'Username/email atau password salah',
        );
      }

      return LoginResult(
        success: true,
        message: 'Login berhasil',
        userData: user,
      );
    } catch (e) {
      return LoginResult(
        success: false,
        message: 'Terjadi kesalahan: $e',
      );
    }
  }

  /// Register function
  Future<RegisterResult> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required bool isFarmer,
    String? farmName,
    String? farmLocation,
  }) async {
    try {
      final users = await _loadUsers(isFarmer);

      // Cek apakah username sudah ada
      final usernameExists = users.any((u) => u['username'] == username);
      if (usernameExists) {
        return RegisterResult(
          success: false,
          message: 'Username sudah digunakan',
        );
      }

      // Cek apakah email sudah ada
      final emailExists = users.any((u) => u['email'] == email);
      if (emailExists) {
        return RegisterResult(
          success: false,
          message: 'Email sudah digunakan',
        );
      }

      // Generate ID baru
      final newId = (users.length + 1).toString();

      // Buat user baru
      final newUser = {
        'id': newId,
        'username': username,
        'email': email,
        'password': password,
        'fullName': fullName,
        'phone': phone,
        'createdAt': DateTime.now().toIso8601String(),
      };

      // Tambahkan field khusus farmer
      if (isFarmer) {
        newUser['farmName'] = farmName ?? '';
        newUser['farmLocation'] = farmLocation ?? '';
      }

      // Tambahkan ke list dan save
      users.add(newUser);
      await _saveUsers(users, isFarmer);

      return RegisterResult(
        success: true,
        message: 'Registrasi berhasil',
        userData: newUser,
      );
    } catch (e) {
      return RegisterResult(
        success: false,
        message: 'Terjadi kesalahan: $e',
      );
    }
  }

  /// Get all users (untuk debugging)
  Future<List<Map<String, dynamic>>> getAllUsers(bool isFarmer) async {
    return await _loadUsers(isFarmer);
  }

  /// Update user data
  Future<bool> updateUser({
    required String userId,
    required Map<String, dynamic> updatedData,
    required bool isFarmer,
  }) async {
    try {
      final users = await _loadUsers(isFarmer);
      final index = users.indexWhere((u) => u['id'] == userId);

      if (index == -1) {
        return false;
      }

      // Update data (keep ID dan createdAt)
      users[index] = {
        ...users[index],
        ...updatedData,
        'id': userId, // Pastikan ID tidak berubah
        'updatedAt': DateTime.now().toIso8601String(),
      };

      await _saveUsers(users, isFarmer);
      return true;
    } catch (e) {
      print('Error updating user: $e');
      return false;
    }
  }

  /// Delete user (opsional)
  Future<bool> deleteUser(String userId, bool isFarmer) async {
    try {
      final users = await _loadUsers(isFarmer);
      users.removeWhere((u) => u['id'] == userId);
      await _saveUsers(users, isFarmer);
      return true;
    } catch (e) {
      print('Error deleting user: $e');
      return false;
    }
  }

  /// Reset password (opsional)
  Future<bool> resetPassword({
    required String email,
    required String newPassword,
    required bool isFarmer,
  }) async {
    try {
      final users = await _loadUsers(isFarmer);
      final index = users.indexWhere((u) => u['email'] == email);

      if (index == -1) {
        return false;
      }

      users[index]['password'] = newPassword;
      users[index]['updatedAt'] = DateTime.now().toIso8601String();

      await _saveUsers(users, isFarmer);
      return true;
    } catch (e) {
      print('Error resetting password: $e');
      return false;
    }
  }
}

/// Model untuk hasil login
class LoginResult {
  final bool success;
  final String message;
  final Map<String, dynamic>? userData;

  LoginResult({
    required this.success,
    required this.message,
    this.userData,
  });
}

/// Model untuk hasil register
class RegisterResult {
  final bool success;
  final String message;
  final Map<String, dynamic>? userData;

  RegisterResult({
    required this.success,
    required this.message,
    this.userData,
  });
}