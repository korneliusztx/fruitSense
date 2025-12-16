// File ini mendefinisikan struktur data untuk setiap item riwayat
class HistoryItem {
  final String id;
  final String fruitName;
  final String quality;
  final double confidence;
  final double? probabilityRaw;
  final String imagePath; // Path lokal untuk gambar yang disimpan
  final String description;
  final DateTime date;

  HistoryItem({
    required this.id,
    required this.fruitName,
    required this.quality,
    required this.confidence,
    this.probabilityRaw,
    required this.imagePath,
    required this.description,
    required this.date,
  });

  // Mengubah objek menjadi Map untuk disimpan di shared_preferences
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fruitName': fruitName,
      'quality': quality,
      'confidence': confidence,
      'probabilityRaw': probabilityRaw,
      'imagePath': imagePath,
      'description': description,
      'date': date.toIso8601String(),
    };
  }

  // Membuat objek dari Map saat data diambil dari shared_preferences
  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['id'],
      fruitName: json['fruitName'],
      quality: json['quality'],
      confidence: json['confidence'],
      probabilityRaw: json['probabilityRaw'],
      imagePath: json['imagePath'],
      description: json['description'],
      date: DateTime.parse(json['date']),
    );
  }
}