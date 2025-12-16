import 'package:flutter/material.dart';
import 'colors.dart';
import 'chat_data.dart'; // Import Global Data

class ChatDetailPage extends StatefulWidget {
  final String name;
  final String imageUrl;
  final bool isVerified;
  final String message; // Pesan awal / Preview

  const ChatDetailPage({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.isVerified,
    required this.message,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Pointer ke data user yang sedang aktif
  Map<String, dynamic>? _currentUserData;

  @override
  void initState() {
    super.initState();
    _initializeChatData();
  }

  // --- LOGIKA UTAMA (PERBAIKAN) ---
  void _initializeChatData() {
    // 1. Coba cari apakah user ini sudah ada di Global List?
    try {
      _currentUserData = globalChatList.firstWhere(
              (user) => user['name'] == widget.name
      );
    } catch (e) {
      _currentUserData = null;
    }

    // 2. JIKA BELUM ADA (Misal dari Petani Favorit), BUAT BARU & SIMPAN
    if (_currentUserData == null) {
      Map<String, dynamic> newUser = {
        "name": widget.name,
        "message": widget.message, // Preview pesan terakhir
        "time": "Today",
        "unreadCount": 0,
        "imageUrl": widget.imageUrl,
        "isVerified": widget.isVerified,
        // PENTING: Masukkan pesan awal ke dalam history agar muncul!
        "chatHistory": [
          {
            "text": widget.message, // Pakai pesan dari parameter
            "time": "Today",
            "isMe": false // Ini pesan dari Penjual
          }
        ],
      };

      // Simpan ke Global List
      globalChatList.add(newUser);

      // Point ke data baru
      _currentUserData = newUser;
    }
    // 3. JIKA SUDAH ADA TAPI HISTORY KOSONG (Jaga-jaga)
    else if (_currentUserData!['chatHistory'] == null || (_currentUserData!['chatHistory'] as List).isEmpty) {
      _currentUserData!['chatHistory'] = [
        {
          "text": widget.message,
          "time": "Today",
          "isMe": false
        }
      ];
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_textController.text.trim().isEmpty) return;
    String newMsg = _textController.text.trim();

    setState(() {
      // Simpan pesan ke Global History
      if (_currentUserData != null) {
        _currentUserData!['chatHistory'].add({
          "text": newMsg,
          "time": "Now",
          "isMe": true, // Pesan Kita
        });

        // Update preview di halaman depan
        _currentUserData!['message'] = newMsg;
        _currentUserData!['time'] = "Now";
      }
    });

    _textController.clear();

    // Auto scroll ke bawah
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isNetworkImage = widget.imageUrl.startsWith('http');

    // Ambil history yang sudah dipastikan ada isinya
    List<dynamic> messages = _currentUserData!['chatHistory'];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[200],
              backgroundImage: isNetworkImage
                  ? NetworkImage(widget.imageUrl)
                  : AssetImage(widget.imageUrl) as ImageProvider,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.name,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (widget.isVerified) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.verified, color: Colors.blue, size: 16),
                    ],
                  ],
                ),
                const Text(
                  "Online",
                  style: TextStyle(color: Colors.green, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return _buildMessageBubble(
                  text: msg['text'],
                  time: msg['time'],
                  isMe: msg['isMe'],
                );
              },
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble({required String text, required String time, required bool isMe}) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : Colors.grey[200],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              text,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                color: isMe ? Colors.white70 : Colors.grey[600],
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  controller: _textController,
                  decoration: const InputDecoration(
                    hintText: "Tulis pesan...",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _sendMessage,
              child: CircleAvatar(
                backgroundColor: AppColors.primary,
                radius: 25,
                child: const Icon(Icons.send, color: Colors.white, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }
}