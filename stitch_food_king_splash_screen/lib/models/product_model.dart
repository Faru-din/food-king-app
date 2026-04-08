class Category {
  final String id;
  final String name;
  final String iconUrl;

  Category({required this.id, required this.name, required this.iconUrl});
}

class ProductAddon {
  final String name;
  final double price;

  ProductAddon({required this.name, required this.price});
}

class Product {
  final String id;
  final String categoryId;
  final String name;
  final String description;
  final double basePrice;
  final String imageUrl;
  final List<String> availableSizes; // e.g. ["Small", "Medium", "Large"]
  final List<ProductAddon> addons;
  final bool isSpecialOffer;

  Product({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.basePrice,
    required this.imageUrl,
    this.availableSizes = const [],
    this.addons = const [],
    this.isSpecialOffer = false,
  });
}
