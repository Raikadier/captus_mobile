class EvidenceItem {
  final String id;
  final String title;
  final String type;
  final String? imagePath;
  final String? qrData;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;

  EvidenceItem({
    required this.id,
    required this.title,
    required this.type,
    this.imagePath,
    this.qrData,
    this.latitude,
    this.longitude,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'imagePath': imagePath,
      'qrData': qrData,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory EvidenceItem.fromMap(Map data) {
    return EvidenceItem(
      id: data['id'],
      title: data['title'],
      type: data['type'],
      imagePath: data['imagePath'],
      qrData: data['qrData'],
      latitude: data['latitude'],
      longitude: data['longitude'],
      createdAt: DateTime.parse(data['createdAt']),
    );
  }
}