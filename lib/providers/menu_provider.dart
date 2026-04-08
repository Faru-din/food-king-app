import 'package:flutter/material.dart';
import '../models/product_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MenuProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Category> _categories = [];
  List<Product> _products = [];
  bool _isLoading = false;

  List<Category> get categories => _categories;
  List<Product> get products => _products;
  List<Product> get specialOffers => _products.where((p) => p.isSpecialOffer).toList();
  bool get isLoading => _isLoading;

  MenuProvider() {
    _loadDummyData(); // Load demo data before Firebase is connected
    // fetchMenu(); // Uncomment after Firebase setup
  }

  void _loadDummyData() {
    _categories = [
      Category(id: 'c1', name: 'Burgers', iconUrl: 'assets/icons/burger.svg'),
      Category(id: 'c2', name: 'Pizza', iconUrl: 'assets/icons/pizza.svg'),
      Category(id: 'c3', name: 'Drinks', iconUrl: 'assets/icons/drink.svg'),
    ];

    _products = [
      Product(
        id: 'p1',
        categoryId: 'c1',
        name: 'Classic Cheeseburger',
        description: 'Juicy beef patty with cheese, lettuce, and our secret sauce.',
        basePrice: 8.99,
        imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&q=80',
        availableSizes: [],
        addons: [
          ProductAddon(name: 'Extra Cheese', price: 1.00),
          ProductAddon(name: 'Bacon', price: 2.00),
        ],
        isSpecialOffer: true,
      ),
      Product(
        id: 'p2',
        categoryId: 'c2',
        name: 'Margherita Pizza',
        description: 'Classic pizza with fresh mozzarella and basil.',
        basePrice: 12.50,
        imageUrl: 'https://images.unsplash.com/photo-1604068549290-dea0e4a305ca?auto=format&fit=crop&q=80',
        availableSizes: ['Small', 'Medium', 'Large'],
        isSpecialOffer: true,
      ),
      Product(
        id: 'p3',
        categoryId: 'c3',
        name: 'Coca Cola',
        description: 'Chilled soda.',
        basePrice: 2.50,
        imageUrl: 'https://images.unsplash.com/photo-1554866585-cd94860890b7?auto=format&fit=crop&q=80',
      ),
    ];
    notifyListeners();
  }

  Future<void> fetchMenu() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Fetch Categories
      QuerySnapshot catSnapshot = await _firestore.collection('categories').get();
      _categories = catSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Category(
          id: doc.id,
          name: data['name'] ?? '',
          iconUrl: data['iconUrl'] ?? '',
        );
      }).toList();

      // Fetch Products
      QuerySnapshot prodSnapshot = await _firestore.collection('products').get();
      _products = prodSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        
        List<ProductAddon> productAddons = [];
        if (data['addons'] != null) {
          productAddons = (data['addons'] as List).map((addon) {
            return ProductAddon(
              name: addon['name'],
              price: (addon['price'] as num).toDouble(),
            );
          }).toList();
        }

        return Product(
          id: doc.id,
          categoryId: data['categoryId'] ?? '',
          name: data['name'] ?? '',
          description: data['description'] ?? '',
          basePrice: (data['basePrice'] as num).toDouble(),
          imageUrl: data['imageUrl'] ?? '',
          availableSizes: List<String>.from(data['availableSizes'] ?? []),
          addons: productAddons,
          isSpecialOffer: data['isSpecialOffer'] ?? false,
        );
      }).toList();

    } catch (e) {
      debugPrint("Error fetching menu: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Product> getProductsByCategory(String categoryId) {
    return _products.where((p) => p.categoryId == categoryId).toList();
  }
}
