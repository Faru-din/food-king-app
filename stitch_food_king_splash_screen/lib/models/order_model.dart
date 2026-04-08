import 'cart_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final String userId;
  final List<CartItem> items;
  final double totalAmount;
  final String status; // e.g. "Pending", "Processing", "Delivered"
  final DateTime createdAt;
  final String paymentMethod;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    required this.paymentMethod,
  });

  factory OrderModel.fromMap(Map<String, dynamic> data, String documentId) {
    return OrderModel(
      id: documentId,
      userId: data['userId'] ?? '',
      items: [], // For simplification, we won't fully parse nested items from Firestore in this boilerplate
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      status: data['status'] ?? 'Pending',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      paymentMethod: data['paymentMethod'] ?? 'COD',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'totalAmount': totalAmount,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'paymentMethod': paymentMethod,
      // 'items': items.map((i) => i.toMap()).toList(), // Need toMap in CartItem
    };
  }
}
