class CategoryModel {
  final String id;
  final String name;
  final String userId;
  final DateTime createdAt;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.userId,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'user_id': userId,
        'created_at': createdAt.toIso8601String(),
      };

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        userId: json['user_id']?.toString() ?? '',
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'])
            : DateTime.now(),
      );
}
