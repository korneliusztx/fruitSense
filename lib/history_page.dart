import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'history_model.dart';
import 'result_page.dart';
import 'colors.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<HistoryItem> _historyList = [];
  List<HistoryItem> _filteredHistoryList = [];
  bool _isLoading = true;
  String _selectedFilter = 'All'; // All, Excellent, Good, Fair
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final historyString = prefs.getString('scan_history');

    if (historyString != null) {
      try {
        final List<dynamic> historyJson = jsonDecode(historyString);
        setState(() {
          _historyList = historyJson.map((json) => HistoryItem.fromJson(json)).toList();
          // Urutkan dari yang terbaru
          _historyList.sort((a, b) => b.date.compareTo(a.date));
          _applyFilters();
        });
        debugPrint('✅ Loaded ${_historyList.length} history items');
      } catch (e) {
        debugPrint('❌ Error loading history: $e');
      }
    } else {
      debugPrint('ℹ️ No history data found');
    }

    setState(() => _isLoading = false);
  }

  void _applyFilters() {
    setState(() {
      _filteredHistoryList = _historyList.where((item) {
        // Filter by quality
        bool matchesFilter = _selectedFilter == 'All' ||
            item.quality.toLowerCase().contains(_selectedFilter.toLowerCase());

        // Filter by search query
        bool matchesSearch = _searchController.text.isEmpty ||
            item.fruitName.toLowerCase().contains(_searchController.text.toLowerCase());

        return matchesFilter && matchesSearch;
      }).toList();
    });
  }

  Future<void> _deleteHistoryItem(String id, String imagePath) async {
    final prefs = await SharedPreferences.getInstance();

    // Hapus file gambar jika ada
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        debugPrint('✅ Image file deleted: $imagePath');
      }
    } catch (e) {
      debugPrint('⚠️ Error deleting image file: $e');
    }

    // Hapus dari list
    setState(() {
      _historyList.removeWhere((item) => item.id == id);
      _applyFilters();
    });

    // Simpan ke shared preferences
    final List<Map<String, dynamic>> historyJson =
    _historyList.map((item) => item.toJson()).toList();
    await prefs.setString('scan_history', jsonEncode(historyJson));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item deleted from history'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _clearAllHistory() async {
    // Konfirmasi dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All History'),
        content: const Text('Are you sure you want to delete all history? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final prefs = await SharedPreferences.getInstance();

    // Hapus semua file gambar
    for (var item in _historyList) {
      try {
        final file = File(item.imagePath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        debugPrint('⚠️ Error deleting image: $e');
      }
    }

    setState(() {
      _historyList.clear();
      _filteredHistoryList.clear();
    });

    await prefs.remove('scan_history');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All history cleared'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _openResultPage(HistoryItem item) {
    // Buat File object dari imagePath
    final imageFile = File(item.imagePath);

    // Navigate ke ResultPage dengan data dari history
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultPage(
          prediction: item.fruitName,
          confidence: item.confidence,
          capturedImage: imageFile,
          probabilityRaw: item.probabilityRaw,
        ),
      ),
    ).then((_) {
      // Reload history ketika kembali dari ResultPage
      _loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Scan History',
          style: TextStyle(
            color: AppColors.textLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textLight),
        actions: [
          if (_historyList.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: _clearAllHistory,
              tooltip: 'Clear All',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Search & Filter Section
          if (_historyList.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    onChanged: (value) => _applyFilters(),
                    decoration: InputDecoration(
                      hintText: 'Search fruit name...',
                      prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _applyFilters();
                        },
                      )
                          : null,
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Excellent'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Good'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Fair'),
                      ],
                    ),
                  ),

                  // Statistics
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Scans: ${_historyList.length}',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          'Showing: ${_filteredHistoryList.length}',
                          style: const TextStyle(
                            color: AppColors.textMutedLight,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          // History List
          Expanded(
            child: _filteredHistoryList.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
              onRefresh: _loadHistory,
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _filteredHistoryList.length,
                itemBuilder: (context, index) {
                  final item = _filteredHistoryList[index];
                  return _buildHistoryCard(item);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = label;
          _applyFilters();
        });
      },
      selectedColor: AppColors.primary,
      backgroundColor: Colors.grey[200],
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textLight,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      checkmarkColor: Colors.white,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchController.text.isNotEmpty || _selectedFilter != 'All'
                ? Icons.search_off
                : Icons.history,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isNotEmpty || _selectedFilter != 'All'
                ? 'No results found'
                : 'No scan history yet',
            style: TextStyle(
              color: AppColors.textMutedLight,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isNotEmpty || _selectedFilter != 'All'
                ? 'Try different search or filter'
                : 'Start scanning fruits to see your history',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(HistoryItem item) {
    final imageFile = File(item.imagePath);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Dismissible(
        key: Key(item.id),
        direction: DismissDirection.endToStart,
        confirmDismiss: (direction) async {
          return await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Delete History'),
              content: const Text('Are you sure you want to delete this item?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Delete'),
                ),
              ],
            ),
          );
        },
        onDismissed: (direction) {
          _deleteHistoryItem(item.id, item.imagePath);
        },
        background: Container(
          decoration: BoxDecoration(
            color: Colors.redAccent,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          alignment: Alignment.centerRight,
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.delete, color: Colors.white, size: 32),
              SizedBox(height: 4),
              Text(
                'Delete',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        child: InkWell(
          onTap: () => _openResultPage(item),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Image preview
                Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: FutureBuilder<bool>(
                        future: imageFile.exists(),
                        builder: (context, snapshot) {
                          if (snapshot.data == true) {
                            return Image.file(
                              imageFile,
                              width: 90,
                              height: 90,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildPlaceholderImage();
                              },
                            );
                          } else {
                            return _buildPlaceholderImage();
                          }
                        },
                      ),
                    ),
                    // Fruit name overlay
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      child: Text(
                        item.fruitName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Quality badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getQualityColor(item.quality),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.quality,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Confidence
                      Row(
                        children: [
                          const Icon(
                            Icons.speed,
                            size: 16,
                            color: AppColors.textMutedLight,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${(item.confidence * 100).toStringAsFixed(1)}% confidence',
                            style: const TextStyle(
                              color: AppColors.textMutedLight,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Description
                      Text(
                        item.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textMutedLight,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Date
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 14,
                                color: AppColors.textMutedLight,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat('MMM dd, yyyy • HH:mm').format(item.date),
                                style: const TextStyle(
                                  color: AppColors.textMutedLight,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: AppColors.textMutedLight,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.image_not_supported,
        color: Colors.grey[500],
        size: 32,
      ),
    );
  }

  Color _getQualityColor(String quality) {
    switch (quality.toLowerCase()) {
      case 'excellent quality':
        return Colors.green;
      case 'good quality':
        return Colors.blue;
      case 'fair quality':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}