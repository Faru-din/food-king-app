import 'package:flutter/material.dart';
import '../models/cart_model.dart';
import '../models/product_model.dart';

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => _items;

  int get itemCount {
    return _items.length;
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.totalPrice;
    });
    return total;
  }

  void addItem(Product product, String? size, List<ProductAddon> addons) {
    // Generate an ID based on product and specific configuration to group identical customized items
    String cartItemId = '${product.id}_${size ?? 'regular'}_${addons.map((e) => e.name).join("-")}';

    if (_items.containsKey(cartItemId)) {
      _items.update(
        cartItemId,
        (existingItem) => CartItem(
          id: existingItem.id,
          product: existingItem.product,
          quantity: existingItem.quantity + 1,
          selectedSize: existingItem.selectedSize,
          selectedAddons: existingItem.selectedAddons,
        ),
      );
    } else {
      _items.putIfAbsent(
        cartItemId,
        () => CartItem(
          id: DateTime.now().toString(),
          product: product,
          quantity: 1,
          selectedSize: size,
          selectedAddons: addons,
        ),
      );
    }
    notifyListeners();
  }

  void removeItem(String cartItemId) {
    _items.remove(cartItemId);
    notifyListeners();
  }

  void removeSingleItem(String cartItemId) {
    if (!_items.containsKey(cartItemId)) return;

    if (_items[cartItemId]!.quantity > 1) {
      _items.update(
        cartItemId,
        (existingItem) => CartItem(
          id: existingItem.id,
          product: existingItem.product,
          quantity: existingItem.quantity - 1,
          selectedSize: existingItem.selectedSize,
          selectedAddons: existingItem.selectedAddons,
        ),
      );
    } else {
      _items.remove(cartItemId);
    }
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
