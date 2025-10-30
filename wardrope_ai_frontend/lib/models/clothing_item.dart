class ClothingItem {
  final String id;
  final String name;
  final String category;
  final String imageUrl;
  final String originalImagePath;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  ClothingItem({
    required this.id,
    required this.name,
    required this.category,
    required this.imageUrl,
    required this.originalImagePath,
    required this.createdAt,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'imageUrl': imageUrl,
      'originalImagePath': originalImagePath,
      'createdAt': createdAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory ClothingItem.fromJson(Map<String, dynamic> json) {
    return ClothingItem(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      imageUrl: json['imageUrl'] as String,
      originalImagePath: json['originalImagePath'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}