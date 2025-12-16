import 'package:flutter/material.dart';
import 'colors.dart'; // Sesuaikan import colors kamu

class LocationPage extends StatelessWidget {
  const LocationPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Data Dummy Lokasi
    final List<String> locations = [
      "Jl. Pemuda No. 15, Semarang Tengah",
      "Perumahan Citra Grand, Tembalang",
      "Jl. Ngesrep Timur V, Banyumanik",
      "Simpang Lima Residence, Semarang",
      "Kampus Binus, POJ City",
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context), // Kembali tanpa bawa data
        ),
        title: const Text("Pilih Lokasi Pengiriman", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      body: ListView.separated(
        itemCount: locations.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.location_on, color: AppColors.primary),
            title: Text(locations[index]),
            onTap: () {
              // --- INI KUNCINYA ---
              // Saat diklik, kita tutup halaman ini SAMBIL membawa data lokasi
              Navigator.pop(context, locations[index]);
            },
          );
        },
      ),
    );
  }
}