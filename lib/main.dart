import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import 'colors.dart';
import 'scan_page.dart';
import 'history_page.dart';
import 'settings_page.dart';
import 'login_page.dart';
import 'product_detail_page.dart';
import 'splash_page.dart';
import 'chat_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FruitSense',
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.backgroundLight,
        primaryColor: AppColors.primary,
        textTheme: GoogleFonts.spaceGroteskTextTheme(
          Theme.of(context).textTheme,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: AppColors.backgroundLight,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: AppColors.textLight,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const SplashPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// --- MAIN PAGE WITH AUTHENTICATION ---
class MainPage extends StatefulWidget {
  final bool showSuccessDialog;
  final Map<String, dynamic>? userData; // Tambahan: terima data user dari auth

  const MainPage({
    super.key,
    this.showSuccessDialog = false,
    this.userData,
  });

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.showSuccessDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showWelcomeDialog();
      });
    }
  }

  void _showWelcomeDialog() {
    // Personalisasi dengan data user
    final username = widget.userData?['username'] ?? 'User';
    final fullName = widget.userData?['fullName'] ?? widget.userData?['username'] ?? 'Pengguna';
    final email = widget.userData?['email'];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 5,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon Success
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: AppColors.primary,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                const Text(
                  "Registrasi Berhasil!",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Personalized Welcome
                Text(
                  "Selamat datang, $fullName!",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),

                // Email (if available)
                if (email != null && email.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],

                const SizedBox(height: 12),

                // Subtitle
                Text(
                  "Siap menjelajahi buah segar?",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Button
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Mulai Jelajah",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      FruitSenseHome(
        onGoToProfile: () => _onItemTapped(3),
        userData: widget.userData, // Pass userData ke FruitSenseHome
      ),
      const HistoryPage(),
      const ChatPage(),
      const SettingsPage(),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      floatingActionButton: Transform.translate(
        offset: const Offset(0, 30),
        child: SizedBox(
          height: 80,
          width: 80,
          child: FloatingActionButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ScanPage()),
            ),
            backgroundColor: AppColors.primary,
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.document_scanner_outlined, size: 30, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildNavIcon(Icons.search, "Explore", 0),
              _buildNavIcon(Icons.history, "History", 1),
              const SizedBox(width: 40),
              _buildNavIcon(Icons.chat_bubble_outline, "Chat", 2),
              _buildNavIcon(Icons.settings_outlined, "Settings", 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, String label, int index) {
    bool isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? AppColors.primary : Colors.grey, size: 26),
          Text(label, style: TextStyle(fontSize: 10, color: isSelected ? AppColors.primary : Colors.grey))
        ],
      ),
    );
  }
}

// --- HALAMAN HOME WITH USER DATA ---
class FruitSenseHome extends StatefulWidget {
  final VoidCallback onGoToProfile;
  final Map<String, dynamic>? userData; // Tambahan: terima userData

  const FruitSenseHome({
    super.key,
    required this.onGoToProfile,
    this.userData,
  });

  @override
  State<FruitSenseHome> createState() => _FruitSenseHomeState();
}

class _FruitSenseHomeState extends State<FruitSenseHome> {
  int _currentCarouselIndex = 0;
  final CarouselSliderController _carouselController = CarouselSliderController();
  bool _isFreshFruitSelected = true;
  String _currentLocation = "Pilih Lokasi Anda";
  bool _isLocationLoading = false;
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  final List<String> imgList = [
    'assets/images/1.jpg',
    'assets/images/2.jpg',
    'assets/images/3.jpg',
    'assets/images/4.jpg',
  ];

  final List<Map<String, String>> _freshFruits = [
    {"name": "Apel Washington", "subtitle": "Rp40.000 /kg", "image": "https://c.pxhere.com/photos/7e/ff/apple_red_reflection_red_apple_food_nature_healthy_fresh-486185.jpg!d"},
    {"name": "Jeruk Santang Madu", "subtitle": "Rp34.000 /kg", "image": "https://upload.wikimedia.org/wikipedia/commons/4/43/Ambersweet_oranges.jpg"},
    {"name": "Mangga Arum Manis", "subtitle": "Rp25.000 /kg", "image": "https://upload.wikimedia.org/wikipedia/commons/9/90/Hapus_Mango.jpg"},
    {"name": "Anggur Merah", "subtitle": "Rp60.000 /kg", "image": "https://images.unsplash.com/photo-1537640538965-1756e1f59226?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80"},
    {"name": "Pisang Cavendish", "subtitle": "Rp22.000 /sisir", "image": "https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80"},
    {"name": "Semangka Merah", "subtitle": "Rp15.000 /buah", "image": "https://images.unsplash.com/photo-1587049352846-4a222e784d38?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80"},
    {"name": "Pisang Susu", "subtitle": "Rp18.000 /sisir", "image": "https://www.static-src.com/wcsstore/Indraprastha/images/catalog/full//105/MTA-69008593/no-brand_buah-pisang-susu_full01.jpg"},
    {"name": "Mangga Kopyor", "subtitle": "Rp20.000 /kg", "image": "https://id-live-01.slatic.net/p/a0475972ebc62abdc04ccfdd91507ed9.jpg"},
    {"name": "Apel Fuji", "subtitle": "Rp32.000 /kg", "image": "https://img.lazcdn.com/g/ff/kf/S9f8f49041b3a4f0db2030f04b6317c20x.jpg_720x720q80.jpg"},
  ];

  final List<Map<String, String>> _processedFruits = [
    {"name": "Asinan Buah", "subtitle": "Pak Adi", "image": "https://blue.kumparan.com/image/upload/fl_progressive,fl_lossy,c_fill,f_auto,q_auto:good,w_640,ar_16:9/v1634025439/8ad98d1ecab6809f4b44118bd90cc5af320f8f14231fd4613f6ac04407b280fb.jpg"},
    {"name": "Kripik Buah", "subtitle": "Bu Tika", "image": "https://matic.sgp1.cdn.digitaloceanspaces.com/jg0qhkxdubcond8kfdks.jpg"},
    {"name": "Rujak Buah", "subtitle": "Mang Asep", "image": "https://i.pinimg.com/1200x/f7/e3/48/f7e3485c0f3b487963af4cc0303cf99e.jpg"},
    {"name": "Manisan Pala", "subtitle": "Oleh-oleh Cianjur", "image": "https://upload.wikimedia.org/wikipedia/commons/thumb/8/87/Manisan_Pala_Basah.jpg/640px-Manisan_Pala_Basah.jpg"},
    {"name": "Kripik Nangka", "subtitle": "Sari Rasa", "image": "https://www.rumahmesin.com/wp-content/uploads/2016/01/ingin-tahu-cara-membuat-keripik-nangka-ini-langkahnya.jpg"},
    {"name": "Jus Alpukat", "subtitle": "Segar Waras", "image": "https://images.unsplash.com/photo-1603569283847-aa295f0d016a?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80"},
    {"name": "Jus Mangga", "subtitle": "Segar Waras", "image": "https://images.unsplash.com/photo-1603569283847-aa295f0d016a?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80"},
  ];

  final List<Map<String, String>> _savedLocations = [
    {"title": "Semarang", "address": "Semarang, Jawa Tengah, Indonesia"},
    {"title": "Jakarta", "address": "Jakarta, Indonesia"},
    {"title": "Surabaya", "address": "Surabaya, Jawa Timur, Indonesia"},
    {"title": "Yogyakarta", "address": "Daerah Istimewa Yogyakarta, Indonesia"},
    {"title": "Bali", "address": "Bali, Indonesia"},
  ];

  @override
  void initState() {
    super.initState();
    _fetchAndSetLocation();
  }

  Future<void> _fetchAndSetLocation() async {
    String? address = await _getFormattedAddress();
    if (address != null && mounted) {
      setState(() {
        _currentLocation = address;
        _isLocationLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<String?> _getFormattedAddress() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return "GPS Mati";

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return "Izin Ditolak";
    }
    if (permission == LocationPermission.deniedForever) return "Izin Permanen Ditolak";

    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String street = place.street ?? "";
        String kelurahan = place.subLocality ?? "";
        String kota = place.subAdministrativeArea ?? "";

        String locationResult = "$street, $kelurahan, $kota";
        locationResult = locationResult.replaceAll(", ,", ",").trim();
        if (locationResult.startsWith(", ")) locationResult = locationResult.substring(2);
        return locationResult;
      }
    } catch (e) {
      return "Gagal memuat lokasi";
    }
    return null;
  }

  List<Map<String, String>> _runFilter() {
    List<Map<String, String>> currentList = _isFreshFruitSelected ? _freshFruits : _processedFruits;
    if (_searchQuery.isEmpty) return currentList;
    return currentList.where((fruit) => fruit["name"]!.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  void _showLocationPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        String? _detectedAddressInModal = (_currentLocation == "Pilih Lokasi Anda" || _currentLocation == "GPS Mati")
            ? null
            : _currentLocation;

        bool _isModalLoading = false;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text("Pilih lokasi tujuan", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                  const SizedBox(height: 20),

                  // TOMBOL GPS
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        setModalState(() => _isModalLoading = true);
                        String? address = await _getFormattedAddress();
                        setModalState(() {
                          _detectedAddressInModal = address;
                          _isModalLoading = false;
                        });
                        if (address != null && mounted) {
                          setState(() {
                            _currentLocation = address;
                          });
                        }
                      },
                      icon: const Icon(Icons.my_location, size: 18, color: AppColors.primary),
                      label: const Text("Gunakan Lokasi Saya (GPS)", style: TextStyle(fontSize: 14, color: AppColors.textLight, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // HASIL DETEKSI GPS
                  if (_isModalLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                    )
                  else if (_detectedAddressInModal != null)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        onTap: () {
                          setState(() => _currentLocation = _detectedAddressInModal!);
                          Navigator.pop(context);
                        },
                        leading: const Icon(Icons.location_on, color: AppColors.primary),
                        title: const Text(
                          "Lokasi saat ini",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                        ),
                        subtitle: Text(
                          _detectedAddressInModal!,
                          style: const TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w500),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),

                  const Text("Alamat tersimpan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),

                  // LIST ALAMAT
                  Expanded(
                    child: ListView.separated(
                      itemCount: _savedLocations.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final loc = _savedLocations[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.location_on, color: Colors.grey),
                          title: Text(loc['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(loc['address']!, maxLines: 2, overflow: TextOverflow.ellipsis),
                          trailing: const Icon(Icons.bookmark_outline, size: 20, color: Colors.grey),
                          onTap: () {
                            setState(() => _currentLocation = loc['address']!);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> displayList = _runFilter();

    return Container(
      color: const Color(0xFFF5F5F5),
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              _buildCarousel(),
              Container(
                margin: const EdgeInsets.only(top: 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLocationHeader(),
                      const SizedBox(height: 24),
                      _buildSearchBar(),
                      const SizedBox(height: 24),
                      _buildCategoryButtons(),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Rekomendasi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textLight)),
                          Text("Lihat lebih", style: TextStyle(fontSize: 14, color: Colors.grey[500])),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (displayList.isEmpty)
                        const Center(child: Padding(padding: EdgeInsets.all(20.0), child: Text("Produk tidak ditemukan", style: TextStyle(color: Colors.grey))))
                      else
                        Column(
                          children: displayList.map((item) {
                            return _buildFruitCard(context, item["name"]!, item["subtitle"]!, item["image"]!);
                          }).toList(),
                        ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationHeader() {
    // Personalisasi dengan userData
    final username = widget.userData?['username'] ?? 'User';
    final firstLetter = username.isNotEmpty ? username[0].toUpperCase() : 'U';

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _showLocationPicker,
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red, size: 28),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Lokasi Anda", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Row(
                      children: [
                        _isLocationLoading
                            ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                            : Text(
                          _currentLocation.length > 20 ? "${_currentLocation.substring(0, 20)}..." : _currentLocation,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textLight),
                        ),
                        const SizedBox(width: 4),
                        if (!_isLocationLoading)
                          const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.textLight),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: widget.onGoToProfile,
          child: CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary,
            child: Text(
              firstLetter,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildCarousel() {
    return Column(
      children: [
        CarouselSlider(
          carouselController: _carouselController,
          options: CarouselOptions(
            height: 180.0,
            autoPlay: true,
            enlargeCenterPage: true,
            aspectRatio: 16 / 9,
            autoPlayCurve: Curves.fastOutSlowIn,
            viewportFraction: 0.9,
            onPageChanged: (index, reason) => setState(() => _currentCarouselIndex = index),
          ),
          items: imgList.map((item) => Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.symmetric(horizontal: 5.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.grey[300],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(item, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.broken_image)),
            ),
          )).toList(),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: imgList.asMap().entries.map((entry) {
            return GestureDetector(
              onTap: () => _carouselController.animateToPage(entry.key),
              child: Container(
                width: 8.0,
                height: 8.0,
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.primary).withOpacity(_currentCarouselIndex == entry.key ? 0.9 : 0.4),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCategoryButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => setState(() {
              _isFreshFruitSelected = true;
              _searchQuery = "";
              _searchController.clear();
            }),
            icon: Image.asset('assets/images/harvest.png', width: 24, height: 24, color: _isFreshFruitSelected ? Colors.white : Colors.grey),
            label: const Text("Buah Segar"),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isFreshFruitSelected ? AppColors.primary : Colors.grey[200],
              foregroundColor: _isFreshFruitSelected ? Colors.white : Colors.grey,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: _isFreshFruitSelected ? 2 : 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => setState(() {
              _isFreshFruitSelected = false;
              _searchQuery = "";
              _searchController.clear();
            }),
            icon: Image.asset('assets/images/drink.png', width: 24, height: 24, color: !_isFreshFruitSelected ? Colors.white : Colors.grey),
            label: const Text("Buah Olahan"),
            style: ElevatedButton.styleFrom(
              backgroundColor: !_isFreshFruitSelected ? AppColors.primary : Colors.grey[200],
              foregroundColor: !_isFreshFruitSelected ? Colors.white : Colors.grey,
              elevation: !_isFreshFruitSelected ? 2 : 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: (value) => setState(() => _searchQuery = value),
      decoration: InputDecoration(
        hintText: 'Cari Produk Petani',
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: const Icon(Icons.search, color: AppColors.textLight),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
          icon: const Icon(Icons.clear, color: Colors.grey),
          onPressed: () => setState(() {
            _searchController.clear();
            _searchQuery = "";
          }),
        )
            : null,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }

  Widget _buildFruitCard(BuildContext context, String name, String subtitle, String imgUrl) {
    final String cleanImgUrl = imgUrl.trim();
    bool isNetworkImage = cleanImgUrl.startsWith('http');
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetailPage(
            fruitName: name,
            price: subtitle,
            imgUrl: cleanImgUrl,
            userLocation: _currentLocation,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 70,
                  height: 70,
                  child: isNetworkImage
                      ? Image.network(cleanImgUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.broken_image, color: Colors.grey))
                      : Image.asset(cleanImgUrl, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[200], child: const Icon(Icons.image_not_supported, color: Colors.grey))),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textLight)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textMutedLight),
            ],
          ),
        ),
      ),
    );
  }
}