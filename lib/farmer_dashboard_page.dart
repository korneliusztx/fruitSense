import 'package:flutter/material.dart';
import 'colors.dart';
import 'manage_products_page.dart'; // Kita buat di langkah 3

class FarmerDashboardPage extends StatelessWidget {
  const FarmerDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Data Dummy Produk (Gambar)
    final List<String> productImages = [
      "https://upload.wikimedia.org/wikipedia/commons/4/43/Ambersweet_oranges.jpg", // Jeruk
      "https://upload.wikimedia.org/wikipedia/commons/9/90/Hapus_Mango.jpg",       // Mangga
      "https://image.idntimes.com/post/20211003/apples-3860991-1920-4821175e6445119390f02cea684cefa8-8122492d983eb9eaec35d4d969bed34a.jpg", // Apel
      "https://asset.kompas.com/crops/NNW_bhM6-molZfQ1Rlfk0sfbEmE=/0x0:750x500/1200x800/data/photo/2024/12/11/6759725d64dc9.jpg" // Salak
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Dashboard",
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        automaticallyImplyLeading: false, // Hilangkan tombol back
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- BAGIAN STATISTIK ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Ringkasan Penjualan",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Lihat lebih",
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Kartu 1: Total Penjualan
            _buildStatCard("Total Penjualan", "Rp 15.000.000", "+10%"),
            const SizedBox(height: 12),

            // Kartu 2: Pesanan Selesai
            _buildStatCard("Pesanan Selesai", "50", "+5%"),
            const SizedBox(height: 12),

            // Kartu 3: Pendapatan
            _buildStatCard("Pendapatan", "Rp 12.000.000", "+8%"),
            const SizedBox(height: 30),

            // --- BAGIAN PRODUK AKTIF ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Produk Aktif",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                // Navigasi ke Halaman Kelola Dagangan
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ManageProductsPage()),
                    );
                  },
                  child: Text(
                    "Lihat lebih",
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Horizontal Scroll List
            SizedBox(
              height: 120, // Tinggi area gambar
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: productImages.length,
                separatorBuilder: (context, index) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      productImages[index],
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (c,e,s) => Container(width: 120, height: 120, color: Colors.grey[300]),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 100), // Spasi bawah untuk navbar
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String growth) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5), // Abu-abu muda
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            growth,
            style: const TextStyle(
              color: AppColors.primary, // Hijau
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}