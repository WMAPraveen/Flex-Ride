class Vehicle {
  final String id;
  final String name;
  final String type;
  final double pricePerDay;
  final String imageBase64;
  bool isRented;
  bool isUnderMaintenance;
  final String? description;
  final String userId;
  String get imageUrl => imageBase64;

  Vehicle({
    required this.id,
    required this.name,
    required this.type,
    required this.pricePerDay,
    required this.imageBase64,
    this.isRented = false,
    this.isUnderMaintenance = false,
    this.description,
    required this.userId,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json, String documentId) {
    return Vehicle(
      id: documentId, // Use Firestore document ID
      name: json['name'] ?? 'Unknown Vehicle',
      type: json['type'] ?? 'Unknown Type',
      pricePerDay: (json['pricePerDay'] as num?)?.toDouble() ?? 0.0,
      imageBase64: json['imageBase64'] ?? '',
      description: json['description'],
      isRented: json['isRented'] ?? false,
      isUnderMaintenance: json['isUnderMaintenance'] ?? false,
      userId: json['userId'] ?? '',
    );
  }

  factory Vehicle.fromMap(Map<String, dynamic> map, String documentId) {
    return Vehicle.fromJson(map, documentId);
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'pricePerDay': pricePerDay,
      'imageBase64': imageBase64,
      'description': description,
      'isRented': isRented,
      'isUnderMaintenance': isUnderMaintenance,
      'userId': userId,
    };
  }
}