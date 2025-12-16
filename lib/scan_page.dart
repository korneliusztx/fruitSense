import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'colors.dart';
import 'result_page.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  // Logic Scanning
  double _progressValue = 0.0;
  Timer? _timer;
  bool _isScanning = false;

  // Logic Kamera
  CameraController? _cameraController;
  bool _isCameraInitialized = false;

  // Logic API
  static const String API_URL = 'http://192.168.1.35:5000/classify';
  // Ganti dengan IP lokal komputer Anda dan port server Flask
  // Pastikan ponsel dan komputer Anda berada di jaringan Wi-Fi yang sama

  String? _classificationResult;
  double? _confidence;
  double? _probabilityRaw;
  File? _capturedImageFile; // Simpan file gambar yang di-capture

  @override
  void initState() {
    super.initState();
    _initializeCamera(); // Mulai nyalakan kamera saat masuk halaman
  }

  // 3. FUNGSI INISIALISASI KAMERA
  Future<void> _initializeCamera() async {
    try {
      // Ambil daftar kamera yang tersedia di HP
      final cameras = await availableCameras();

      if (cameras.isNotEmpty) {
        // Pilih kamera belakang (biasanya index 0)
        _cameraController = CameraController(
          cameras[0],
          ResolutionPreset.high, // Kualitas tinggi
          enableAudio: false,
        );

        await _cameraController!.initialize();

        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      debugPrint("Error initializing camera: $e");
    }
  }

  // 4. FUNGSI AMBIL DARI GALERI
  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);

      // Simpan file gambar
      setState(() {
        _capturedImageFile = imageFile;
      });

      // Jika user memilih gambar, langsung jalankan animasi scan dan kirim ke API
      _startScanningAnimation(imageFile);
    }
  }

  // 5. FUNGSI CAPTURE DARI KAMERA
  Future<void> _captureFromCamera() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      debugPrint("Camera not initialized");
      return;
    }

    try {
      final XFile image = await _cameraController!.takePicture();
      final imageFile = File(image.path);

      // Simpan file gambar
      setState(() {
        _capturedImageFile = imageFile;
      });

      // Jalankan animasi scan dan kirim ke API
      _startScanningAnimation(imageFile);
    } catch (e) {
      debugPrint("Error capturing image: $e");
    }
  }

  // 6. FUNGSI MENGIRIM GAMBAR KE API DAN MENERIMA HASIL
  Future<void> _classifyImageViaApi(File image) async {
    try {
      // 1. Buat permintaan multipart (untuk mengirim file)
      var request = http.MultipartRequest('POST', Uri.parse(API_URL));

      // 2. Tambahkan file gambar ke permintaan
      request.files.add(
        await http.MultipartFile.fromPath(
          'image', // Nama field harus sesuai dengan 'image' di server
          image.path,
        ),
      );

      // 3. Kirim permintaan
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        // Berhasil menerima respons
        final jsonResponse = jsonDecode(response.body);

        // Sesuaikan dengan response Flask Anda
        if (jsonResponse['success'] == true) {
          final prediction = jsonResponse['prediction'] ?? 'Unknown';
          final confidence = jsonResponse['confidence'] ?? 0.0;
          final probabilityRaw = jsonResponse['probability_raw'] ?? 0.0;

          setState(() {
            _classificationResult = prediction;
            _confidence = confidence;
            _probabilityRaw = probabilityRaw;
          });

          debugPrint('✅ Hasil API:');
          debugPrint('   Prediction: $prediction');
          debugPrint('   Confidence: $confidence');
          debugPrint('   Probability Raw: $probabilityRaw');
        } else {
          // Success false dari API
          setState(() {
            _classificationResult = 'Error';
            _confidence = 0.0;
          });
          debugPrint('❌ API returned success: false');
        }
      } else {
        // Error dari server
        final errorMessage = jsonDecode(response.body)['error'] ?? 'Unknown error';
        setState(() {
          _classificationResult = 'Error';
          _confidence = 0.0;
        });
        debugPrint('❌ Error Server (${response.statusCode}): $errorMessage');
      }
    } catch (e) {
      // Error koneksi
      setState(() {
        _classificationResult = 'Connection Error';
        _confidence = 0.0;
      });
      debugPrint('❌ Error Koneksi: $e');
      debugPrint('   Pastikan:');
      debugPrint('   1. Server Flask berjalan (python app.py)');
      debugPrint('   2. IP address benar: $API_URL');
      debugPrint('   3. HP dan PC di WiFi yang sama');
      debugPrint('   4. Firewall tidak memblokir port 5000');
    }
  }

  void _startScanningAnimation(File imageFile) async {
    if (_isScanning) return;

    setState(() {
      _isScanning = true;
      _progressValue = 0.0;
      _classificationResult = null;
      _confidence = null;
      _probabilityRaw = null;
    });

    // Kirim gambar ke API secara paralel dengan animasi
    _classifyImageViaApi(imageFile);

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 40), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_progressValue < 1.0) {
          _progressValue += 0.01;
        } else {
          timer.cancel();
          _isScanning = false;
          _navigateToResultPage();
        }
      });
    });
  }

  void _navigateToResultPage() {
    if (!mounted) return;

    // Kirim hasil klasifikasi DAN gambar ke ResultPage
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => ResultPage(
          prediction: _classificationResult ?? 'Unknown',
          confidence: _confidence ?? 0.0,
          capturedImage: _capturedImageFile, // Kirim gambar yang di-capture
          probabilityRaw: _probabilityRaw, // Kirim juga probability raw jika diperlukan
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cameraController?.dispose(); // Matikan kamera saat keluar halaman agar tidak memory leak
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ukuran layar untuk menyesuaikan preview kamera
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black, // Background hitam saat loading kamera
      body: Stack(
        children: [
          // --- LAYER 1: KAMERA PREVIEW (Gantikan Gambar Apel) ---
          if (_isCameraInitialized && _cameraController != null)
            SizedBox(
              width: size.width,
              height: size.height,
              child: CameraPreview(_cameraController!),
            )
          else
            const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),

          // --- LAYER 2: APP BAR ---
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              title: const Text('Scan Fruit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              backgroundColor: Colors.transparent, // Transparan agar kamera terlihat
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),

          // --- LAYER 3: FRAME FOKUS (Opsional: Agar terlihat seperti scanner beneran) ---
          if (!_isScanning)
            Center(
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _cornerIcon(0), // Kiri Atas
                        _cornerIcon(1), // Kanan Atas
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _cornerIcon(3), // Kiri Bawah
                        _cornerIcon(2), // Kanan Bawah
                      ],
                    ),
                  ],
                ),
              ),
            ),

          // --- LAYER 4: BOTTOM SHEET ---
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              decoration: const BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Posisikan buah di tengah',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Pastikan cahaya cukup terang',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textMutedLight,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // CONTROLS ROW
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Rata tengah
                    children: [
                      // 1. TOMBOL GALERI (KIRI)
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.borderLight,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.photo_library_outlined, color: AppColors.textLight),
                          iconSize: 28,
                          onPressed: _pickFromGallery, // Panggil fungsi galeri
                        ),
                      ),

                      // 2. TOMBOL SCAN (TENGAH)
                      GestureDetector(
                        onTap: _captureFromCamera, // Capture dari kamera
                        child: Container(
                          height: 72,
                          width: 72,
                          decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: [
                                BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 10, spreadRadius: 2)
                              ]
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 32),
                        ),
                      ),

                      // 3. TOMBOL KANAN (DUMMY/HILANG)
                      // Kita pakai SizedBox kosong dengan ukuran sama agar tombol scan tetap persis di tengah
                      const SizedBox(width: 48, height: 48),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // LOADING INDICATOR
                  if (_isScanning)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Menganalisa...',
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: _progressValue,
                          backgroundColor: AppColors.borderLight,
                          color: AppColors.primary,
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ],
                    )
                  else
                    const SizedBox(height: 29),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  // Helper untuk membuat siku pojok frame fokus
  Widget _cornerIcon(int quarterTurns) {
    return RotatedBox(
      quarterTurns: quarterTurns,
      child: const Icon(Icons.crop_free, color: Colors.white, size: 30),
    );
  }
}