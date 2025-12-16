import 'package:flutter/material.dart';
import 'colors.dart';

class ManageProductsPage extends StatefulWidget {
  const ManageProductsPage({super.key});

  @override
  State<ManageProductsPage> createState() => _ManageProductsPageState();
}

class _ManageProductsPageState extends State<ManageProductsPage> {
  // 1. DATA PRODUK
  List<Map<String, dynamic>> products = [
    {
      "name": "Jeruk Santang Madu",
      "rating": "4.5",
      "stock": "100kg",
      "image": "https://upload.wikimedia.org/wikipedia/commons/4/43/Ambersweet_oranges.jpg"
    },
    {
      "name": "Mangga Arum Manis",
      "rating": "4.7",
      "stock": "75kg",
      "image": "https://upload.wikimedia.org/wikipedia/commons/9/90/Hapus_Mango.jpg"
    },
    {
      "name": "Apel Washington",
      "rating": "4.6",
      "stock": "80kg",
      "image": "https://image.idntimes.com/post/20211003/apples-3860991-1920-4821175e6445119390f02cea684cefa8-8122492d983eb9eaec35d4d969bed34a.jpg"
    },
    {
      "name": "Salak Bali",
      "rating": "4.8",
      "stock": "50kg",
      "image": "https://asset.kompas.com/crops/NNW_bhM6-molZfQ1Rlfk0sfbEmE=/0x0:750x500/1200x800/data/photo/2024/12/11/6759725d64dc9.jpg"
    },
  ];

  // 2. FUNGSI HAPUS PRODUK (Update Style Notifikasi)
  void _deleteProduct(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Hapus Produk"),
          content: Text("Apakah Anda yakin ingin menghapus '${products[index]['name']}'?"),
          actions: [
            TextButton(
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Hapus", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              onPressed: () {
                setState(() {
                  products.removeAt(index);
                });
                Navigator.of(context).pop();

                // Bersihkan notif lama agar tidak menumpuk
                ScaffoldMessenger.of(context).clearSnackBars();

                // Tampilkan Notifikasi Gaya Floating (Sama seperti Petani Favorit)
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("Produk berhasil dihapus"),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating, // Melayang
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Membulat
                    ),
                    margin: const EdgeInsets.all(20), // Margin sekeliling
                    backgroundColor: const Color(0xFF333333), // Warna Dark Grey elegan
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 3. Tambahkan PopScope agar notif hilang saat tekan Back di HP
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (didPop) {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
            onPressed: () {
              // Hapus notif saat tekan tombol back di AppBar
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              Navigator.pop(context);
            },
          ),
          title: const Text(
            "Kelola Dagangan",
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Colors.black, size: 28),
              onPressed: () {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("Fitur Tambah Produk akan segera hadir!"),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    margin: const EdgeInsets.all(20),
                    backgroundColor: const Color(0xFF333333),
                  ),
                );
              },
            ),
            const SizedBox(width: 12),
          ],
        ),
        body: products.isEmpty
            ? _buildEmptyState()
            : ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: products.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final item = products[index];
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      item['image'],
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(width: 70, height: 70, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['name'],
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star, size: 14, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text(
                              "${item['rating']} | Stok: ${item['stock']}",
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20, color: Colors.black87),
                        onPressed: () {
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Edit ${item['name']}"),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              margin: const EdgeInsets.all(20),
                              backgroundColor: const Color(0xFF333333),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                        onPressed: () {
                          _deleteProduct(index);
                        },
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text("Belum ada produk", style: TextStyle(color: Colors.grey[500], fontSize: 16)),
        ],
      ),
    );
  }
}