class Product {
  final int id;
  final String title, category, thumbnail, brand, description;
  final double price, rating, discount;
  final int stock;
  final List<String> images;

  Product({
    required this.id,
    required this.title,
    required this.category,
    required this.thumbnail,
    required this.price,
    this.brand = '',
    this.description = '',
    this.rating = 0,
    this.discount = 0,
    this.stock = 0,
    this.images = const [],
  });

  factory Product.fromJson(Map<String, dynamic> j) => Product(
        id: j['id'],
        title: j['title'] ?? '',
        category: j['category'] ?? '',
        thumbnail: j['thumbnail'] ?? '',
        price: (j['price'] ?? 0).toDouble(),
        brand: j['brand'] ?? '',
        description: j['description'] ?? '',
        rating: (j['rating'] ?? 0).toDouble(),
        discount: (j['discountPercentage'] ?? 0).toDouble(),
        stock: j['stock'] ?? 0,
        images: List<String>.from(j['images'] ?? []),
      );

  Map<String, dynamic> toMap(String username) => {
        'id': id,
        'username': username,
        'title': title,
        'category': category,
        'price': price,
        'thumbnail': thumbnail,
      };

  factory Product.fromMap(Map<String, dynamic> m) => Product(
        id: m['id'],
        title: m['title'],
        category: m['category'],
        price: m['price'],
        thumbnail: m['thumbnail'],
      );
}