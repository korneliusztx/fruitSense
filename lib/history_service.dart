import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'history_model.dart';

class HistoryService {
  static const String _historyKey = 'scan_history';
  static const _uuid = Uuid();

  // Fungsi untuk menyimpan hasil scan ke history
  static Future<void> saveToHistory({
    required String fruitName,
    required String quality,
    required double confidence,
    double? probabilityRaw,
    required File imageFile,
    required String description,
  }) async {
    try {
      // 1. Simpan gambar ke direktori aplikasi
      final directory = await getApplicationDocumentsDirectory();
      final historyImagesDir = Directory('${directory.path}/history_images');

      // Buat folder jika belum ada
      if (!await historyImagesDir.exists()) {
        await historyImagesDir.create(recursive: true);
      }

      // Generate unique filename
      final String filename = '${_uuid.v4()}.jpg';
      final String imagePath = '${historyImagesDir.path}/$filename';

      // Copy file ke lokasi baru
      final savedImage = await imageFile.copy(imagePath);
      debugPrint('✅ Image saved to: $imagePath');

      // 2. Buat HistoryItem
      final historyItem = HistoryItem(
        id: _uuid.v4(),
        fruitName: fruitName,
        quality: quality,
        confidence: confidence,
        probabilityRaw: probabilityRaw,
        imagePath: savedImage.path,
        description: description,
        date: DateTime.now(),
      );

      // 3. Ambil history yang sudah ada
      final prefs = await SharedPreferences.getInstance();
      final historyString = prefs.getString(_historyKey);

      List<HistoryItem> historyList = [];
      if (historyString != null) {
        final List<dynamic> historyJson = jsonDecode(historyString);
        historyList = historyJson.map((json) => HistoryItem.fromJson(json)).toList();
      }

      // 4. Tambahkan item baru di awal list
      historyList.insert(0, historyItem);

      // 5. Limit history ke 50 item terakhir (optional)
      if (historyList.length > 50) {
        // Hapus item lama dan file gambarnya
        final removedItems = historyList.sublist(50);
        for (var item in removedItems) {
          try {
            final file = File(item.imagePath);
            if (await file.exists()) {
              await file.delete();
            }
          } catch (e) {
            debugPrint('⚠️ Error deleting old image: $e');
          }
        }
        historyList = historyList.sublist(0, 50);
      }

      // 6. Simpan kembali ke SharedPreferences
      final historyJson = historyList.map((item) => item.toJson()).toList();
      await prefs.setString(_historyKey, jsonEncode(historyJson));

      debugPrint('✅ History saved successfully');
    } catch (e) {
      debugPrint('❌ Error saving to history: $e');
      rethrow;
    }
  }

  // Fungsi untuk mendapatkan semua history
  static Future<List<HistoryItem>> getHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyString = prefs.getString(_historyKey);

      if (historyString == null) {
        return [];
      }

      final List<dynamic> historyJson = jsonDecode(historyString);
      final historyList = historyJson.map((json) => HistoryItem.fromJson(json)).toList();

      // Urutkan dari yang terbaru
      historyList.sort((a, b) => b.date.compareTo(a.date));

      return historyList;
    } catch (e) {
      debugPrint('❌ Error loading history: $e');
      return [];
    }
  }

  // Fungsi untuk menghapus semua history
  static Future<void> clearAllHistory() async {
    try {
      final historyList = await getHistory();

      // Hapus semua file gambar
      for (var item in historyList) {
        try {
          final file = File(item.imagePath);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (e) {
          debugPrint('⚠️ Error deleting image: $e');
        }
      }

      // Hapus dari SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_historyKey);

      debugPrint('✅ All history cleared');
    } catch (e) {
      debugPrint('❌ Error clearing history: $e');
      rethrow;
    }
  }
}