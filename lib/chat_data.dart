// chat_data.dart

List<Map<String, dynamic>> globalChatList = [
  // 1. FRUIT SENSE (Chat default/sistem)
  {
    "name": "Fruit Sense",
    "message": "Hey there, welcome! Ready to be healthy?",
    "time": "Today",
    "unreadCount": 1,
    "imageUrl": "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?ixlib=rb-1.2.1&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80",
    "isVerified": true,
    "chatHistory": [
      {
        "text": "Hey there, welcome! Ready to be healthy?",
        "time": "Today",
        "isMe": false
      }
    ],
  },

  // 2. KEBUN PAK YANTO (Skenario: Diskusi Stok Mangga)
  {
    "name": "Kebun Pak Yanto",
    "message": "Siap mas, ditunggu orderannya.", // Preview pesan terakhir
    "time": "Yesterday",
    "unreadCount": 0,
    "imageUrl": "assets/images/Pak_Yanto.jpg",
    "isVerified": false,
    // --- RIWAYAT CHAT YANG SUDAH ADA ---
    "chatHistory": [
      {
        "text": "Halo Pak Yanto, mangga arumanis ready stok?",
        "time": "Yesterday 09:00",
        "isMe": true // Kita tanya
      },
      {
        "text": "Ready mas, baru panen tadi pagi. Manis-manis lho.",
        "time": "Yesterday 09:05",
        "isMe": false // Pak Yanto jawab
      },
      {
        "text": "Wah mantap. Kalau beli 5kg ada diskon nggak pak?",
        "time": "Yesterday 09:10",
        "isMe": true // Kita nego
      },
      {
        "text": "Waduh harga pas mas hehe, tapi nanti saya pilihin yang paling besar-besar deh.",
        "time": "Yesterday 09:12",
        "isMe": false // Pak Yanto jawab
      },
      {
        "text": "Oke deh pak, saya checkout di aplikasi ya.",
        "time": "Yesterday 09:15",
        "isMe": true // Kita setuju
      },
      {
        "text": "Siap mas, ditunggu orderannya.",
        "time": "Yesterday 09:16",
        "isMe": false // Pak Yanto konfirmasi
      }
    ],
  },

  // 3. TOKO BUAH SARI (Skenario: Komplain/Konfirmasi Barang)
  {
    "name": "Toko Buah Sari",
    "message": "Terima kasih kembali kak!",
    "time": "Mon",
    "unreadCount": 0,
    "imageUrl": "assets/images/Toko_Buah_Sari.jpg",
    "isVerified": true,
    // --- RIWAYAT CHAT YANG SUDAH ADA ---
    "chatHistory": [
      {
        "text": "Kak, paket buah naga saya sudah sampai.",
        "time": "Mon 13:00",
        "isMe": true
      },
      {
        "text": "Alhamdulillah, kondisinya aman kak?",
        "time": "Mon 13:05",
        "isMe": false
      },
      {
        "text": "Aman kak, masih segar banget. Makasih ya packingnya rapi.",
        "time": "Mon 13:10",
        "isMe": true
      },
      {
        "text": "Terima kasih kembali kak! Ditunggu orderan selanjutnya ya.",
        "time": "Mon 13:15",
        "isMe": false
      }
    ],
  },

  // --- DATA PETANI FAVORIT (BELUM ADA HISTORY / DEFAULT) ---
  // History akan otomatis dibuat saat tombol chat ditekan (sesuai logika di favorite_farmers_page)
  {
    "name": "Frutopia",
    "message": "Stok apel fuji baru masuk kak, segar!",
    "time": "Sun",
    "unreadCount": 5,
    "imageUrl": "assets/images/Frutopia.png",
    "isVerified": true,
    // Kita kosongkan chatHistory-nya (atau isi null), biar nanti dihandle logic 'User Baru'
    "chatHistory": null,
  },
  {
    "name": "Buahin.id",
    "message": "Pesanan kakak sedang dipacking ya",
    "time": "Sat",
    "unreadCount": 0,
    "imageUrl": "assets/images/Buahin.png",
    "isVerified": true,
    "chatHistory": null,
  },
  {
    "name": "Fresh Mart",
    "message": "Promo diskon 50% berakhir hari ini",
    "time": "Fri",
    "unreadCount": 1,
    "imageUrl": "assets/images/Fresh Mart.png",
    "isVerified": true,
    "chatHistory": null,
  },
];