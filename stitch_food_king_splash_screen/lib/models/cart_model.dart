import 'product_model.dart';

class CartItem {
  final String id;
  final Product product;
  int quantity;
  final String? selectedSize;
  final List<ProductAddon> selectedAddons;

  CartItem({
    required this.id,
    required this.product,
    this.quantity = 1,
    this.selectedSize,
    this.selectedAddons = const [],
  });

  double get totalPrice {
    double addonsTotal = selectedAddons.fold(0, (sum, addon) => sum + addon.price);
    return (product.basePrice + addonsTotal) * quantity;
  }
}
