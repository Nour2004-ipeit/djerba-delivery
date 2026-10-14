import 'package:flutter/foundation.dart';
import '../../cart/data/orders_api.dart';

class PastOrder {
  final String id;
  final String restaurantId;
  final String restaurantName;
  final String restaurantImage;
  final DateTime date;
  final double total;
  final String status;
  final List<OrderItem> items;

  PastOrder({
    required this.id,
    required this.restaurantId,
    required this.restaurantName,
    required this.restaurantImage,
    required this.date,
    required this.total,
    required this.status,
    required this.items,
  });
}

class OrderItem {
  final String productId;
  final String title;
  final double price;
  final String imageUrl;
  final String? description;
  final int quantity;

  OrderItem({
    required this.productId,
    required this.title,
    required this.price,
    required this.imageUrl,
    this.description,
    required this.quantity,
  });
}

class OrderService extends ChangeNotifier {
  static final OrderService _instance = OrderService._internal();
  
  factory OrderService() {
    return _instance;
  }
  
  OrderService._internal() {
    fetchOrders();
  }

  List<PastOrder> _pastOrders = [];
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  List<PastOrder> get pastOrders => _pastOrders;

  Future<void> fetchOrders() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await OrdersApi().getOrders();
      _pastOrders = data.map((json) {
        final orderItems = (json['items'] as List<dynamic>?) ?? [];
        return PastOrder(
          id: json['id'] ?? '',
          restaurantId: json['restaurantId'] ?? '',
          restaurantName: json['restaurant']?['name'] ?? 'Restaurant inconnu',
          restaurantImage: json['restaurant']?['imageUrl'] ?? 'https://images.unsplash.com/photo-1541518763669-27fef04b14ea?auto=format&fit=crop&q=80&w=800',
          date: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
          total: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
          status: json['status'] ?? 'pending',
          items: orderItems.map((item) => OrderItem(
            productId: item['productId'] ?? '',
            title: item['productNameSnapshot'] ?? 'Produit',
            price: (item['unitPriceSnapshot'] as num?)?.toDouble() ?? 0.0,
            quantity: item['quantity'] ?? 1,
            imageUrl: item['product']?['imageUrl'] ?? 'https://images.unsplash.com/photo-1541518763669-27fef04b14ea?auto=format&fit=crop&q=80&w=800',
          )).toList(),
        );
      }).toList();
      
      // Sort newest first
      _pastOrders.sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      print('Error fetching orders: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
