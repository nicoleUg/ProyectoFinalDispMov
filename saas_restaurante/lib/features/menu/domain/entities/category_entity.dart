class CategoryEntity {
  final String id;
  final String name;
  final String? imageUrl;
  final int orderIndex; 

  CategoryEntity({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.orderIndex,
  });
}