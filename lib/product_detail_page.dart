import 'package:flutter/material.dart';
import 'colors.dart';
import 'dart:math' as math;
import 'payment_page.dart'; // Pastikan import payment page ada

class ProductDetailPage extends StatefulWidget {
  final String fruitName;
  final String price;
  final String imgUrl;
  final String userLocation; // 1. Menerima data lokasi dari Main Page

  const ProductDetailPage({
    super.key,
    required this.fruitName,
    required this.price,
    required this.imgUrl,
    required this.userLocation, // Wajib diisi
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _selectedStoreIndex = 0;
  bool _isFavorite = false;

  // List Toko yang akan ditampilkan (hasil filter)
  List<Map<String, dynamic>> _filteredStores = [];

  // 2. DATABASE DUMMY LENGKAP (Semarang, Jakarta, Surabaya, Bali, dll)
  final List<Map<String, dynamic>> _allStores = [
    // --- SEMARANG ---
    {
      "name": "Kebun Pak Yanto",
      "location": "Ngaliyan, Semarang",
      "city": "Semarang",
      "rating": 4.5,
      "stock": "100kg",
      "image": "assets/images/Pak_Yanto.jpg",
    },
    {
      "name": "Toko Buah Sari",
      "location": "Simpang Lima, Semarang",
      "city": "Semarang",
      "rating": 4.6,
      "stock": "50kg",
      "image": "assets/images/Toko_Buah_Sari.jpg",
    },
    {
      "name": "Grow a Garden",
      "location": "Simpang Lima, Semarang",
      "city": "Semarang",
      "rating": 4.6,
      "stock": "50kg",
      "image": "assets/images/Grow a Garden.png",
    },

    // --- JAKARTA ---
    {
      "name": "Fresh Market Jaksel",
      "location": "Tebet, Jakarta Selatan",
      "city": "Jakarta",
      "rating": 4.8,
      "stock": "200kg",
      "image": "assets/images/Fresh_market.png",
    },
    {
      "name": "Buah Segar Menteng",
      "location": "Menteng, Jakarta Pusat",
      "city": "Jakarta",
      "rating": 4.7,
      "stock": "85kg",
      "image": "https://segargroupindonesia.com/wp-content/uploads/2021/09/buah-dari-indonesia.jpg",
    },

    // --- SURABAYA ---
    {
      "name": "Juragan Buah Suroboyo",
      "location": "Gubeng, Surabaya",
      "city": "Surabaya",
      "rating": 4.9,
      "stock": "150kg",
      "image": "https://nibble-images.b-cdn.net/nibble/original_images/jakarta_buah_gofruit_2199739c3e.jpg",
    },

    // --- BALI ---
    {
      "name": "Bali Fresh Fruit",
      "location": "Denpasar, Bali",
      "city": "Bali",
      "rating": 4.8,
      "stock": "90kg",
      "image": "assets/images/Bali_fresh_fruit.png",
    },

    // --- YOGYAKARTA ---
    {
      "name": "Buah Malioboro",
      "location": "Malioboro, Yogyakarta",
      "city": "Yogyakarta",
      "rating": 4.6,
      "stock": "40kg",
      "image": "https://lapispahlawan.co.id/uploads/6/2023-07/toko_buah_di_surabaya.jpg",
    },
  ];

  @override
  void initState() {
    super.initState();
    _filterStores();
  }

  // 3. FUNGSI FILTER TOKO BERDASARKAN LOKASI USER
  void _filterStores() {
    // Logika: Cari toko yang 'city'-nya ada di dalam string 'userLocation'
    // Contoh: User di "Semarang, Indonesia" -> Cari toko dengan city "Semarang"

    _filteredStores = _allStores.where((store) {
      return widget.userLocation.contains(store['city']);
    }).toList();

    // Fallback: Jika tidak ada toko di kota tersebut, tampilkan semua (atau tampilkan pesan kosong)
    if (_filteredStores.isEmpty) {
      // Opsi A: Tampilkan toko random (misal 3 teratas)
      _filteredStores = _allStores.take(3).toList();
    }
  }

  void _showPurchaseBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.50,
          child: _PurchaseBottomSheetContent(
            fruitName: widget.fruitName,
            priceString: widget.price,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String cleanImgUrl = widget.imgUrl.trim();
    bool isNetworkImage = cleanImgUrl.startsWith('http');

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  IconButton(
                    icon: const Icon(Icons.share_outlined),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Transform.rotate(
                            angle: math.pi / 4,
                            child: Container(
                              width: 220, height: 220,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Transform.rotate(
                            angle: math.pi / 4,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: SizedBox(
                                width: 200, height: 200,
                                child: isNetworkImage
                                    ? Image.network(cleanImgUrl, fit: BoxFit.cover, errorBuilder: (c,e,s) => Container(color: Colors.grey[200]))
                                    : Image.asset(cleanImgUrl, fit: BoxFit.cover, errorBuilder: (c,e,s) => Container(color: Colors.grey[200])),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 60),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.fruitName,
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.price,
                              style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () => setState(() => _isFavorite = !_isFavorite),
                          icon: Icon(
                            _isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: _isFavorite ? Colors.red : Colors.grey[400],
                            size: 32,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // HEADER LIST TOKO (Dinamis sesuai lokasi)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Toko Terdekat", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                        // Menampilkan lokasi yang sedang aktif
                        if (_filteredStores.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8)),
                            child: Text(
                              "di ${widget.userLocation.split(',')[0]}", // Ambil nama kota saja
                              style: TextStyle(fontSize: 12, color: Colors.green[800], fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // LIST TOKO (Hanya menampilkan _filteredStores)
                    if (_filteredStores.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text("Belum ada mitra toko di daerah ini.", style: TextStyle(color: Colors.grey)),
                      )
                    else
                      ...List.generate(_filteredStores.length, (index) {
                        final store = _filteredStores[index];
                        final isSelected = _selectedStoreIndex == index;

                        ImageProvider imageProvider;
                        if (store['image'].startsWith('http')) {
                          imageProvider = NetworkImage(store['image']);
                        } else {
                          // Pastikan nama file di aset tidak ada spasi (contoh: pak_yanto.jpg)
                          imageProvider = AssetImage(store['image']);
                        }

                        return GestureDetector(
                          onTap: () => setState(() => _selectedStoreIndex = index),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFFFFFC2) : const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(20),
                              border: isSelected ? Border.all(color: Colors.yellow[700]!, width: 1) : Border.all(color: Colors.transparent),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.white,
                                  backgroundImage: imageProvider, // Gunakan variabel yang sudah dicek
                                  onBackgroundImageError: (exception, stackTrace) {
                                    // Handler jika gambar gagal dimuat (Internet mati / Aset typo)
                                    debugPrint('Error loading image: $exception');
                                  },
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(store['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                      Text(store['location'], style: TextStyle(fontSize: 12, color: Colors.grey[600]), maxLines: 1),
                                      Row(
                                        children: [
                                          const Icon(Icons.star, size: 14, color: Colors.orange),
                                          Text(" ${store['rating']} | Stok: ${store['stock']}", style: TextStyle(fontSize: 12, color: Colors.grey[800])),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected) const Icon(Icons.radio_button_checked, color: AppColors.primary),
                                if (!isSelected) const Icon(Icons.radio_button_off, color: Colors.grey),
                              ],
                            ),
                          ),
                        );
                      }),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
        ),
        child: ElevatedButton(
          onPressed: () {
            _showPurchaseBottomSheet(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline),
              SizedBox(width: 8),
              Text('Beli Sekarang', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

// --- WIDGET KONTEN BOTTOM SHEET (FINAL VERSION) ---
class _PurchaseBottomSheetContent extends StatefulWidget {
  final String fruitName;
  final String priceString;

  const _PurchaseBottomSheetContent({
    super.key,
    required this.fruitName,
    required this.priceString,
  });

  @override
  State<_PurchaseBottomSheetContent> createState() => _PurchaseBottomSheetContentState();
}

class _PurchaseBottomSheetContentState extends State<_PurchaseBottomSheetContent> {
  int quantity = 1;
  bool isDelivery = false;
  int pricePerKg = 0;

  @override
  void initState() {
    super.initState();
    String cleanPrice = widget.priceString.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanPrice.isNotEmpty) {
      pricePerKg = int.parse(cleanPrice);
    }
  }

  String formatCurrency(int amount) {
    final str = amount.toString();
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    String result = str.replaceAllMapped(reg, (Match m) => '${m[1]}.');
    return "Rp$result";
  }

  @override
  Widget build(BuildContext context) {
    int totalPrice = pricePerKg * quantity;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.fruitName,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              Text(
                widget.priceString,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => isDelivery = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(color: !isDelivery ? AppColors.primary : Colors.transparent, borderRadius: BorderRadius.circular(10)),
                      alignment: Alignment.center,
                      child: Text("Pick up", style: TextStyle(color: !isDelivery ? Colors.white : Colors.grey, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => isDelivery = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(color: isDelivery ? AppColors.primary : Colors.transparent, borderRadius: BorderRadius.circular(10)),
                      alignment: Alignment.center,
                      child: Text("Delivery", style: TextStyle(color: isDelivery ? Colors.white : Colors.grey, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: isDelivery ? 80 : 0,
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12), image: const DecorationImage(image: NetworkImage("https://static.vecteezy.com/system/resources/previews/000/552/683/original/geo-location-pin-vector-icon.jpg"), fit: BoxFit.cover, opacity: 0.4)),
                  alignment: Alignment.center,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Icon(Icons.location_on, color: AppColors.primary), SizedBox(width: 8), Text("Set your location here...", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500))],
                  ),
                ),
              ),
            ),
          ),
          Row(
            children: [
              InkWell(
                onTap: () { if (quantity > 1) setState(() => quantity--); },
                child: Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.yellow[200], borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.remove, color: Colors.black)),
              ),
              const SizedBox(width: 16),
              Text("$quantity", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(width: 16),
              InkWell(
                onTap: () => setState(() => quantity++),
                child: Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.add, color: Colors.white)),
              ),
              const SizedBox(width: 12),
              const Text("kg", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 4),
          const Text("(Min 1 kg)*", style: TextStyle(color: Colors.red, fontSize: 12)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text("Total ", style: TextStyle(fontSize: 16, color: Colors.black54)),
              Text(formatCurrency(totalPrice), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
            ],
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentPage(totalPrice: formatCurrency(totalPrice))));
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text("Bayar Sekarang", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}