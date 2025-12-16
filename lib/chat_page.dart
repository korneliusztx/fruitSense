import 'package:flutter/material.dart';
import 'colors.dart';
import 'chat_detail_page.dart';
import 'favorite_farmers_page.dart';
import 'chat_data.dart'; // 1. IMPORT DATA GLOBAL

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // Data chatList lokal DIHAPUS, kita pakai globalChatList

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 80,
        title: Row(
          children: [
            Expanded(
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari',
                    hintStyle: TextStyle(color: Colors.grey),
                    prefixIcon: Icon(Icons.search, color: Colors.black54),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            InkWell(
              onTap: () async {
                // Tunggu sampai kembali dari halaman favorit, lalu refresh
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FavoriteFarmersPage()),
                );
                setState(() {}); // Refresh halaman saat kembali (agar notif hilang)
              },
              borderRadius: BorderRadius.circular(50),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Icon(Icons.bookmark_outline, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
      // 2. GUNAKAN GLOBAL CHAT LIST
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: globalChatList.length,
        itemBuilder: (context, index) {
          final item = globalChatList[index]; // Ambil dari global
          return _buildChatItem(
            context,
            index: index,
            name: item['name'],
            message: item['message'],
            time: item['time'],
            unreadCount: item['unreadCount'],
            imageUrl: item['imageUrl'],
            isVerified: item['isVerified'],
          );
        },
      ),
    );
  }

  Widget _buildChatItem(
      BuildContext context, {
        required int index,
        required String name,
        required String message,
        required String time,
        required int unreadCount,
        required String imageUrl,
        required bool isVerified,
      }) {
    bool isNetworkImage = imageUrl.startsWith('http');

    return InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailPage(
              name: name,
              imageUrl: imageUrl,
              isVerified: isVerified,
              message: message,
            ),
          ),
        );
        // Update di global data
        setState(() {
          globalChatList[index]['unreadCount'] = 0;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.grey[200],
              backgroundImage: isNetworkImage
                  ? NetworkImage(imageUrl)
                  : AssetImage(imageUrl) as ImageProvider,
              onBackgroundImageError: (e,s){},
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      if (isVerified) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.verified, color: Colors.blue, size: 16),
                      ]
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: unreadCount > 0 ? Colors.black87 : Colors.grey,
                      fontWeight: unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: unreadCount > 0 ? Colors.red : Colors.grey,
                    fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 6),
                if (unreadCount > 0)
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}