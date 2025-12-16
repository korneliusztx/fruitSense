import 'package:flutter/material.dart';
import 'colors.dart';
// IMPORT HALAMAN DETAIL PEMBAYARAN
import 'payment_bank_transfer_page.dart';
import 'payment_credit_card_page.dart';
import 'payment_qris_page.dart';

class PaymentPage extends StatelessWidget {
  final String totalPrice;

  const PaymentPage({super.key, required this.totalPrice});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          "Fruit Sense",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- BAGIAN HEADER & TOTAL ---
            Stack(
              children: [
                Container(
                  height: 80,
                  color: AppColors.primary,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Total", style: TextStyle(color: Colors.grey)),
                          RichText(
                            text: const TextSpan(
                              style: TextStyle(color: Colors.grey, fontSize: 12),
                              children: [
                                TextSpan(text: "Pilih dalam "),
                                TextSpan(
                                  text: "00:29:59",
                                  style: TextStyle(
                                      color: Colors.red, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            totalPrice,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Order ID #1234567890",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // --- JUDUL METODE ---
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Metode Pembayaran",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- LIST METODE PEMBAYARAN (SUDAH BISA DIKLIK) ---

            // 1. Transfer Bank
            _buildPaymentMethod(
              context: context,
              title: "Transfer Bank",
              logos: [
                "https://upload.wikimedia.org/wikipedia/commons/thumb/5/5c/Bank_Central_Asia.svg/2560px-Bank_Central_Asia.svg.png",
                "https://upload.wikimedia.org/wikipedia/commons/thumb/a/ad/Bank_Mandiri_logo_2016.svg/1200px-Bank_Mandiri_logo_2016.svg.png",
                "https://upload.wikimedia.org/wikipedia/id/thumb/5/55/BNI_logo.svg/1200px-BNI_logo.svg.png",
                "https://upload.wikimedia.org/wikipedia/commons/thumb/6/68/BANK_BRI_logo.svg/1280px-BANK_BRI_logo.svg.png",
              ],
              onTap: () {
                // Navigasi ke Halaman Transfer Bank
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentBankTransferPage(totalPrice: totalPrice),
                  ),
                );
              },
            ),

            // 2. Kartu Kredit/Debit
            _buildPaymentMethod(
              context: context,
              title: "Kartu kredit/debit",
              logos: [
                "https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/Visa_Inc._logo.svg/2560px-Visa_Inc._logo.svg.png",
                "https://upload.wikimedia.org/wikipedia/commons/thumb/2/2a/Mastercard-logo.svg/1280px-Mastercard-logo.svg.png",
                "https://upload.wikimedia.org/wikipedia/commons/thumb/4/40/JCB_logo.svg/1280px-JCB_logo.svg.png",
                "https://upload.wikimedia.org/wikipedia/commons/thumb/3/30/American_Express_logo.svg/1200px-American_Express_logo.svg.png",
              ],
              onTap: () {
                // Navigasi ke Halaman Kartu Kredit
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentCreditCardPage(totalPrice: totalPrice),
                  ),
                );
              },
            ),

            // 3. Gopay/QRIS
            _buildPaymentMethod(
              context: context,
              title: "Gopay/QRIS",
              logos: [
                "https://upload.wikimedia.org/wikipedia/commons/thumb/8/86/Gopay_logo.svg/2560px-Gopay_logo.svg.png",
                "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a2/Logo_QRIS.svg/2560px-Logo_QRIS.svg.png",
              ],
              onTap: () {
                // Navigasi ke Halaman QRIS
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentQrisPage(totalPrice: totalPrice),
                  ),
                );
              },
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // WIDGET HELPER UPDATE (TAMBAH onTap)
  Widget _buildPaymentMethod({
    required BuildContext context,
    required String title,
    required List<String> logos,
    required VoidCallback onTap, // Parameter Fungsi Klik
  }) {
    return InkWell( // Membuat area bisa diklik dengan efek air (ripple)
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ...logos.map((url) => Container(
                      margin: const EdgeInsets.only(right: 10),
                      width: 40,
                      height: 25,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Image.network(
                        url,
                        fit: BoxFit.contain,
                        errorBuilder: (c, e, s) => const Icon(Icons.error, size: 10),
                      ),
                    )),
                    const Spacer(),
                    const Icon(Icons.chevron_right, color: Colors.black),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
        ],
      ),
    );
  }
}