import 'package:flutter/material.dart';
import 'dart:convert';

class CartItem {
  final String id;
  final String productId;
  final String restaurantId;
  final String name;
  final double price;
  final String imageUrl;
  final String? description;
  final Map<String, String> options;
  int quantity;

  CartItem({
    required this.id,
    required this.productId,
    required this.restaurantId,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.description,
    this.options = const {},
    this.quantity = 1,
  });
}

class CartService extends ChangeNotifier {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => _items;

  int get totalItems => _items.values.fold(0, (sum, item) => sum + item.quantity);
  
  double get totalPrice => _items.values.fold(0.0, (sum, item) => sum + (item.price * item.quantity));

  int getQuantity(String itemId) {
    return _items[itemId]?.quantity ?? 0;
  }

  int getTotalQuantityForDish(String name) {
    return _items.values.where((item) => item.name == name).fold(0, (sum, item) => sum + item.quantity);
  }

  String _generateId(String name, Map<String, String> options) {
    if (options.isEmpty) return name;
    final sortedKeys = options.keys.toList()..sort();
    final optionsString = sortedKeys.map((k) => '${k}=${options[k]}').join('|');
    return '${name}_${optionsString}';
  }

  void addItem(String productId, String restaurantId, String name, double price, String imageUrl, {String? description, Map<String, String> options = const {}, int quantity = 1}) {
    final id = _generateId(name, options);
    
    if (_items.containsKey(id)) {
      _items[id]!.quantity += quantity;
    } else {
      _items[id] = CartItem(
        id: id,
        productId: productId,
        restaurantId: restaurantId,
        name: name,
        price: price,
        imageUrl: imageUrl,
        description: description,
        options: options,
        quantity: quantity,
      );
    }
    notifyListeners();
  }

  void removeItem(String id) {
    if (!_items.containsKey(id)) return;
    
    if (_items[id]!.quantity > 1) {
      _items[id]!.quantity--;
    } else {
      _items.remove(id);
    }
    notifyListeners();
  }
  
  void removeCompletely(String id) {
    _items.remove(id);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
