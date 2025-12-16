import 'package:flutter/material.dart';
import 'colors.dart';
import 'farmer_dashboard_page.dart';
import 'history_page.dart';
import 'scan_page.dart';
import 'chat_page.dart';
import 'settings_page.dart';

class FarmerMainPage extends StatefulWidget {
  final bool showSuccessDialog;
  final Map<String, dynamic>? userData; // Tambahan: terima data farmer dari auth

  const FarmerMainPage({
    super.key,
    this.showSuccessDialog = false,
    this.userData,
  });

  @override
  State<FarmerMainPage> createState() => _FarmerMainPageState();
}

class _FarmerMainPageState extends State<FarmerMainPage> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    // Initialize pages dengan userData (jika page butuh userData, pass ke constructor)
    _pages = [
      const FarmerDashboardPage(),  // Jika FarmerDashboardPage butuh userData, tambahkan: FarmerDashboardPage(userData: widget.userData)
      const HistoryPage(),
      const ChatPage(),
      const SettingsPage(),
    ];

    // Cek apakah harus menampilkan Dialog Sambutan
    if (widget.showSuccessDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showWelcomeDialog();
      });
    }
  }

  // FUNGSI POP-UP SAMBUTAN (KHUSUS PETANI) - WITH PERSONALIZATION
  void _showWelcomeDialog() {
    // Ambil data farmer untuk personalisasi dialog
    final username = widget.userData?['username'] ?? 'Petani';
    final fullName = widget.userData?['fullName'] ?? widget.userData?['username'] ?? 'Mitra Petani';
    final farmName = widget.userData?['farmName'];
    final farmLocation = widget.userData?['farmLocation'];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 5,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon dengan Background
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.agriculture, // Icon Agriculture untuk Petani
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

                // Personalized Welcome Message
                Text(
                  "Selamat datang, $fullName!",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),

                // Farm Info (if available)
                if (farmName != null && farmName.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    farmName,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],

                if (farmLocation != null && farmLocation.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          farmLocation,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 12),

                // Subtitle
                Text(
                  "Siap pasarkan hasil panenmu?",
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
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Mulai Berjualan",
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
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      floatingActionButton: Transform.translate(
        offset: const Offset(0, 30),
        child: SizedBox(
          height: 80,
          width: 80,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ScanPage()),
              );
            },
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
              _buildNavIcon(Icons.storefront_outlined, "Store", 0),
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
          Icon(
            icon,
            color: isSelected ? AppColors.primary : Colors.grey,
            size: 26,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isSelected ? AppColors.primary : Colors.grey,
            ),
          )
        ],
      ),
    );
  }
}