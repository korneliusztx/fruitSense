import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'colors.dart';
import 'history_service.dart';

class ResultPage extends StatefulWidget {
  final String prediction;
  final double confidence;
  final File? capturedImage;
  final double? probabilityRaw;

  const ResultPage({
    super.key,
    required this.prediction,
    required this.confidence,
    this.capturedImage,
    this.probabilityRaw,
  });

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  // Gemini API Configuration
  static const String GEMINI_API_KEY = 'AIzaSyDWqsucNytWtqTQLgppR3tajESD4sBitaE';
  static const String GEMINI_API_URL =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  // State untuk tips dari Gemini
  String? _geminiTips;
  bool _isLoadingTips = false;
  String? _errorMessage;
  bool _isSavedToHistory = false;

  @override
  void initState() {
    super.initState();
    _fetchTipsFromGemini();
  }

  // Fungsi untuk menyimpan ke history (DIPANGGIL SETELAH TIPS DIMUAT)
  Future<void> _saveToHistory() async {
    if (_isSavedToHistory) {
      debugPrint('⚠️ Already saved to history, skipping...');
      return;
    }

    try {
      if (widget.capturedImage == null) {
        debugPrint('⚠️ No image to save to history');
        return;
      }

      final quality = _getQualityFromConfidence(widget.confidence);

      // Gunakan tips dari Gemini jika sudah dimuat, atau gunakan default tips
      final description = _geminiTips ?? _getDefaultTips();

      debugPrint('💾 Saving to history...');
      debugPrint('   Fruit: ${widget.prediction}');
      debugPrint('   Quality: $quality');
      debugPrint('   Confidence: ${widget.confidence}');

      await HistoryService.saveToHistory(
        fruitName: widget.prediction,
        quality: quality,
        confidence: widget.confidence,
        probabilityRaw: widget.probabilityRaw,
        imageFile: widget.capturedImage!,
        description: description.length > 200
            ? '${description.substring(0, 197)}...'
            : description,
      );

      setState(() => _isSavedToHistory = true);
      debugPrint('✅ Saved to history successfully');
    } catch (e) {
      debugPrint('❌ Error saving to history: $e');
    }
  }

  // Fungsi untuk memanggil Gemini API
  Future<void> _fetchTipsFromGemini() async {
    setState(() {
      _isLoadingTips = true;
      _errorMessage = null;
    });

    try {
      final prompt = _buildPrompt();

      final requestBody = jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": prompt}
            ]
          }
        ],
        "generationConfig": {
          "temperature": 0.7,
          "maxOutputTokens": 300,
        }
      });

      final response = await http.post(
        Uri.parse('$GEMINI_API_URL?key=$GEMINI_API_KEY'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final text = jsonResponse['candidates'][0]['content']['parts'][0]['text'];

        setState(() {
          _geminiTips = text.trim();
          _isLoadingTips = false;
        });

        debugPrint('✅ Gemini Tips berhasil dimuat');

        // ✅ SAVE KE HISTORY SETELAH TIPS BERHASIL DIMUAT
        await _saveToHistory();
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Error fetching Gemini tips: $e');
      setState(() {
        _errorMessage = 'Gagal memuat tips dari AI';
        _isLoadingTips = false;
        _geminiTips = _getDefaultTips();
      });

      // ✅ TETAP SAVE KE HISTORY MESKIPUN GAGAL LOAD TIPS (DENGAN DEFAULT TIPS)
      await _saveToHistory();
    }
  }

  String _buildPrompt() {
    final fruitName = widget.prediction;
    final quality = _getQualityFromConfidence(widget.confidence);

    return '''
You are a fruit selection expert. Based on the following information:
- Fruit Type: $fruitName
- Quality Level: $quality
- Confidence: ${(widget.confidence * 100).toStringAsFixed(1)}%

Please provide practical and specific tips for selecting high-quality $fruitName when shopping. 
Keep the response concise (2-3 sentences), focus on visual indicators, texture, smell, and weight that consumers should check.
Write in a friendly, conversational Indonesian language.
''';
  }

  String _getDefaultTips() {
    final fruitName = widget.prediction.toLowerCase();
    return 'Saat memilih $fruitName, perhatikan warna yang cerah dan merata, tekstur kulit yang halus tanpa memar, dan pastikan terasa berat untuk ukurannya yang menandakan kandungan air yang baik. Hindari buah dengan bintik lunak atau perubahan warna yang tidak wajar.';
  }

  String _getQualityFromConfidence(double confidence) {
    if (confidence >= 0.9) {
      return 'Excellent Quality';
    } else if (confidence >= 0.75) {
      return 'Good Quality';
    } else if (confidence >= 0.5) {
      return 'Fair Quality';
    } else {
      return 'Low Confidence';
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = AppColors.primary;
    const Color textColor = Colors.white;
    final Color subtleTextColor = Colors.white.withOpacity(0.7);
    final Color chipColor = const Color(0xFF4E9F3D);
    String quality = _getQualityFromConfidence(widget.confidence);

    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: backgroundColor,
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: textColor,
          displayColor: textColor,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        iconTheme: const IconThemeData(color: textColor),
      ),
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primary,
                AppColors.primary.withOpacity(0.8),
              ],
            ),
          ),
          child: CustomScrollView(
            slivers: <Widget>[
              // App Bar dengan gambar hasil capture
              SliverAppBar(
                expandedHeight: 250.0,
                pinned: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                ),
                actions: [
                  // Indicator bahwa sudah disimpan ke history
                  if (_isSavedToHistory)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle, color: Colors.white, size: 16),
                              SizedBox(width: 4),
                              Text(
                                'Saved',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: const Text('Fruit Quality'),
                  background: widget.capturedImage != null
                      ? Image.file(
                    widget.capturedImage!,
                    fit: BoxFit.cover,
                    color: Colors.black.withOpacity(0.3),
                    colorBlendMode: BlendMode.darken,
                  )
                      : Image.network(
                    'https://c.pxhere.com/photos/7e/ff/apple_red_reflection_red_apple_food_nature_healthy_fresh-486185.jpg!d',
                    fit: BoxFit.cover,
                    color: Colors.black.withOpacity(0.3),
                    colorBlendMode: BlendMode.darken,
                  ),
                ),
              ),

              // Konten utama
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hasil Kualitas dan Nama Buah
                      Center(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: chipColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                quality,
                                style: const TextStyle(fontWeight: FontWeight.bold, color: textColor),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.prediction,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Confidence Score
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'Confidence Score',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: subtleTextColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${(widget.confidence * 100).toStringAsFixed(1)}%',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                  if (widget.probabilityRaw != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        'Raw: ${(widget.probabilityRaw! * 100).toStringAsFixed(2)}%',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: subtleTextColor.withOpacity(0.6),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Quality Checklist
                      const Text(
                        'Quality Checklist',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      _buildChecklistItem(
                        title: 'Color',
                        subtitle: 'Vibrant and uniform, typical for the variety.',
                        iconColor: Colors.white,
                        subtleColor: subtleTextColor,
                      ),
                      _buildChecklistItem(
                        title: 'Firmness',
                        subtitle: 'Firm to the touch, not soft or mushy.',
                        iconColor: Colors.white,
                        subtleColor: subtleTextColor,
                      ),
                      _buildChecklistItem(
                        title: 'Skin',
                        subtitle: 'Smooth and free of blemishes, bruises, or wrinkles.',
                        iconColor: Colors.white,
                        subtleColor: subtleTextColor,
                      ),
                      _buildChecklistItem(
                        title: 'Weight',
                        subtitle: 'Feels heavy for its size, indicating juiciness.',
                        iconColor: Colors.white,
                        subtleColor: subtleTextColor,
                      ),
                      const SizedBox(height: 30),

                      // Tips for Selection (POWERED BY GEMINI AI)
                      Row(
                        children: [
                          const Text(
                            'Tips for Selection',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.purple.shade400,
                                  Colors.blue.shade400,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.auto_awesome, color: Colors.white, size: 14),
                                SizedBox(width: 4),
                                Text(
                                  'AI',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: _buildTipsContent(subtleTextColor),
                      ),

                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Center(
                            child: TextButton.icon(
                              onPressed: _fetchTipsFromGemini,
                              icon: const Icon(Icons.refresh, color: Colors.white70),
                              label: const Text(
                                'Coba Lagi',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipsContent(Color subtleTextColor) {
    if (_isLoadingTips) {
      return const Column(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Memuat tips dari AI...',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      );
    }

    if (_errorMessage != null && _geminiTips == null) {
      return Column(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.orange.shade300,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage!,
            style: TextStyle(
              color: subtleTextColor,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return Text(
      _geminiTips ?? _getDefaultTips(),
      style: TextStyle(
        fontSize: 16,
        color: subtleTextColor,
        height: 1.5,
      ),
      textAlign: TextAlign.justify,
    );
  }

  Widget _buildChecklistItem({
    required String title,
    required String subtitle,
    required Color iconColor,
    required Color subtleColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              border: Border.all(color: iconColor, width: 2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(Icons.check, color: iconColor, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: subtleColor, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}