class Product {
  final String id;
  final String name;
  final double basePrice;
  final String categoryId;
  final String? imageUrl;

  const Product({
    required this.id,
    required this.name,
    required this.basePrice,
    required this.categoryId,
    this.imageUrl,
  });
}
