import 'package:flutter/material.dart';
import 'colors.dart';
import 'chat_detail_page.dart';
import 'chat_data.dart'; // Import data global

class FavoriteFarmersPage extends StatefulWidget {
  const FavoriteFarmersPage({super.key});

  @override
  State<FavoriteFarmersPage> createState() => _FavoriteFarmersPageState();
}

class _FavoriteFarmersPageState extends State<FavoriteFarmersPage> {
  // Data Petani Favorit
  List<Map<String, dynamic>> farmers = [
    {
      "name": "Frutopia",
      "rating": "4.9",
      "reviews": "1k+ Ulasan",
      "image": "assets/images/Frutopia.png",
    },
    {
      "name": "Buahin.id",
      "rating": "4.8",
      "reviews": "500+ Ulasan",
      "image": "assets/images/Buahin.png",
    },
    {
      "name": "Fresh Mart",
      "rating": "4.9",
      "reviews": "500+ Ulasan",
      "image": "assets/images/Fresh Mart.png",
    },
  ];

  void _removeFavorite(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Hapus Favorit"),
          content: Text("Yakin ingin menghapus '${farmers[index]['name']}'?"),
          actions: [
            TextButton(
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text("Hapus", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              onPressed: () {
                setState(() => farmers.removeAt(index));
                Navigator.pop(context);

                // BERSIHKAN NOTIFIKASI LAMA (JIKA ADA)
                ScaffoldMessenger.of(context).clearSnackBars();

                // TAMPILKAN NOTIFIKASI BARU (MARGIN NORMAL)
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("Berhasil dihapus"),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    // CUKUP ALL 20 KARENA TIDAK ADA NAVBAR DI SINI
                    margin: const EdgeInsets.all(20),
                    backgroundColor: const Color(0xFF333333),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _openChat(String farmerName, String farmerImage) {
    Map<String, dynamic>? existingChat;
    try {
      existingChat = globalChatList.firstWhere((chat) => chat['name'] == farmerName);
    } catch (e) {
      existingChat = null;
    }

    String messageToSend;
    if (existingChat != null) {
      messageToSend = existingChat['message'];
      setState(() { existingChat!['unreadCount'] = 0; });
    } else {
      messageToSend = "Halo kak, saya tertarik dengan produk ini.";
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDetailPage(
          name: farmerName,
          imageUrl: farmerImage,
          isVerified: true,
          message: messageToSend,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // PopScope digunakan agar saat tekan Back HP, notifikasi hilang
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
              // Hapus notif saat tekan tombol back di UI
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              Navigator.pop(context);
            },
          ),
          title: const Text('Petani Favorit', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 20)),
        ),
        body: farmers.isEmpty
            ? Center(child: Text("Belum ada petani favorit", style: TextStyle(color: Colors.grey[500])))
            : ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: farmers.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final item = farmers[index];
            return _buildFarmerCard(
              index: index,
              name: item['name'],
              rating: item['rating'],
              reviews: item['reviews'],
              imageUrl: item['image'],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFarmerCard({
    required int index,
    required String name,
    required String rating,
    required String reviews,
    required String imageUrl,
  }) {
    bool isNetworkImage = imageUrl.startsWith('http');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            backgroundImage: isNetworkImage ? NetworkImage(imageUrl) : AssetImage(imageUrl) as ImageProvider,
            onBackgroundImageError: (e,s){},
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
                    const SizedBox(width: 4),
                    const Icon(Icons.verified, color: Colors.blue, size: 16),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: AppColors.primary, size: 16),
                    const SizedBox(width: 4),
                    Text(rating, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(width: 4),
                    Text("•  $reviews", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          Row(
            children: [
              _buildActionButton(Icons.chat_bubble_outline, AppColors.primary, Colors.white, () => _openChat(name, imageUrl)),
              const SizedBox(width: 8),
              _buildActionButton(Icons.delete_outline, Colors.white, Colors.red, () => _removeFavorite(index), borderColor: Colors.red),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color bgColor, Color iconColor, VoidCallback onTap, {Color? borderColor}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor ?? bgColor),
      ),
      child: IconButton(padding: EdgeInsets.zero, icon: Icon(icon, color: iconColor, size: 20), onPressed: onTap),
    );
  }
}