class CategoryModel {
  final int id;
  final String name;
  final String userId;
  final DateTime? createdAt;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.userId,
    this.createdAt,
  });

  bool get isGeneral => name.toLowerCase() == 'general';

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      userId: json['user_id'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'user_id': userId,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  CategoryModel copyWith({
    int? id,
    String? name,
    String? userId,
    DateTime? createdAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}