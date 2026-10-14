import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/cart_item_model.dart';

class CartState {
  final Map<String, CartItem> items;
  
  CartState({this.items = const {}});

  CartState copyWith({Map<String, CartItem>? items}) {
    return CartState(items: items ?? this.items);
  }

  int get totalItems => items.values.fold(0, (sum, item) => sum + item.quantity);
  double get totalPrice => items.values.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
}

class CartNotifier extends Notifier<CartState> {
  @override
  CartState build() {
    return CartState();
  }

  void addItem(String id, String name, double price, int quantity) {
    final newItems = Map<String, CartItem>.from(state.items);
    if (newItems.containsKey(id)) {
      final item = newItems[id]!;
      newItems[id] = item.copyWith(quantity: item.quantity + quantity);
    } else {
      newItems[id] = CartItem(
        productId: id, 
        name: name, 
        price: price, 
        quantity: quantity
      );
    }
    state = state.copyWith(items: newItems);
  }

  void removeItem(String id) {
    final newItems = Map<String, CartItem>.from(state.items);
    if (!newItems.containsKey(id)) return;
    
    final item = newItems[id]!;
    if (item.quantity > 1) {
      newItems[id] = item.copyWith(quantity: item.quantity - 1);
    } else {
      newItems.remove(id);
    }
    state = state.copyWith(items: newItems);
  }

  void clear() {
    state = CartState();
  }
}

final cartProvider = NotifierProvider<CartNotifier, CartState>(() => CartNotifier());
