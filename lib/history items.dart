class HistoryItem {
  final String id;
  final String diagnosisClass; // One of: "lung_aca", "lung_n", "lung_scc"
  final String diagnosisTitle; // Human-readable diagnosis title
  final String imagePath;
  final DateTime dateTime;
  final double confidence;
  final Map<String, dynamic> diagnosisInfo;

  HistoryItem({
    required this.id,
    required this.diagnosisClass,
    required this.diagnosisTitle,
    required this.imagePath,
    required this.dateTime,
    required this.confidence,
    required this.diagnosisInfo,
  });

  // Ensure the toMap() method generates a valid map to be encoded as JSON
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'diagnosisClass': diagnosisClass,
      'diagnosisTitle': diagnosisTitle,
      'imagePath': imagePath,
      'dateTime': dateTime.toIso8601String(),
      'confidence': confidence,
      'diagnosisInfo': diagnosisInfo,
    };
  }

  // Ensure fromMap() correctly parses the map from JSON
  factory HistoryItem.fromMap(Map<String, dynamic> map) {
    return HistoryItem(
      id: map['id'] ?? '',
      diagnosisClass: map['diagnosisClass'] ?? '',
      diagnosisTitle: map['diagnosisTitle'] ?? '',
      imagePath: map['imagePath'] ?? '',
      dateTime: DateTime.parse(map['dateTime']),
      confidence: map['confidence'] is double
          ? map['confidence']
          : (map['confidence'] is int ? map['confidence'].toDouble() : 0.0),
      diagnosisInfo: Map<String, dynamic>.from(map['diagnosisInfo'] ?? {}),
    );
  }
}