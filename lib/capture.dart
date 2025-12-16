import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http; // Import HTTP
import 'dart:convert'; // Untuk handle JSON

class CapturePage extends StatefulWidget {
  const CapturePage({super.key});
  // ... (sisa State, dll.)
  @override
  State<CapturePage> createState() => _CapturePageState();
}

class _CapturePageState extends State<CapturePage> {
  File? _image;
  String _classificationResult = 'Siap Klasifikasi';
  final ImagePicker _picker = ImagePicker();

  // Ganti dengan IP lokal komputer Anda dan port server Flask
  static const String API_URL = 'http://192.168.187.164:5000/classify';
  // Pastikan ponsel dan komputer Anda berada di jaringan Wi-Fi yang sama

  @override
  void initState() {
    super.initState();
    _classificationResult = 'Server API: ${API_URL}';
  }

  // --- Fungsi untuk Mengirim dan Menerima Hasil dari API ---
  Future<void> _classifyImageViaApi(File image) async {
    setState(() => _classificationResult = 'Mengirim gambar ke API lokal...');

    try {
      // 1. Buat permintaan multipart (untuk mengirim file)
      var request = http.MultipartRequest('POST', Uri.parse(API_URL));

      // 2. Tambahkan file gambar ke permintaan
      request.files.add(
        await http.MultipartFile.fromPath(
          'image', // Nama field harus sesuai dengan 'image' di server (request.files['image'])
          image.path,
        ),
      );

      // 3. Kirim permintaan
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        // Berhasil menerima respons
        final jsonResponse = jsonDecode(response.body);

        final prediction = jsonResponse['prediction'] ?? 'N/A';
        final confidence = (jsonResponse['confidence'] * 100).toStringAsFixed(2);

        setState(() {
          _classificationResult = '✅ Hasil API: ${prediction}\nKepercayaan: ${confidence}%';
        });

      } else {
        // Error dari server (misalnya 400, 500)
        setState(() {
          _classificationResult = '❌ Error Server (${response.statusCode}): ${response.body}';
        });
      }
    } catch (e) {
      // Error koneksi (misalnya server mati, IP salah)
      setState(() {
        _classificationResult = '❌ Error Koneksi: Pastikan server Python berjalan dan IP (${API_URL}) sudah benar. Error: $e';
      });
      debugPrint('Error: $e');
    }
  }


  // --- Update _captureImage untuk Memanggil Fungsi API ---
  Future<void> _captureImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final tempImageFile = File(pickedFile.path);

      setState(() {
        _image = tempImageFile;
      });

      // Panggil fungsi API
      await _classifyImageViaApi(tempImageFile);

      debugPrint('Gambar diambil.');
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... (widget build tetap sama, hanya menampilkan _classificationResult)
    return Scaffold(
      appBar: AppBar(
        title: const Text('Klasifikasi Via API Lokal'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ... tampilan gambar ...
              // ... tampilan hasil klasifikasi ...
              // ... tombol ambil gambar ...
              _image == null
                  ? const Text(
                'Tekan tombol untuk mengambil gambar',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              )
                  : ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _image!,
                  width: 250,
                  height: 250,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blueAccent),
                ),
                child: Text(
                  _classificationResult,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _captureImage,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Ambil Gambar & Klasifikasi (API)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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