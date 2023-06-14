class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final List<String> images;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.images,
  });

  factory Product.fromMap(Map<String, dynamic> data, String documentId) {
    List<String> images = [];
    for (var image in data['images']) {
      images.add(image);
    }
    return Product(
      id: documentId,
      name: data['title'] ?? '',
      description: data['description'] ?? '',
      price: (data['discount_price'] ?? 0.0).toDouble(),
      images: images,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': name,
      'description': description,
      'discount_price': price,
      'images': images,
    };
  }
}
