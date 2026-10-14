import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models.dart';
import '../data/orders_api.dart';

final ordersApiProvider = Provider((ref) => OrdersApi());

final ordersProvider = StreamProvider.autoDispose<List<OrderModel>>((ref) async* {
  while (true) {
    yield await ref.read(ordersApiProvider).getOrders();
    await Future.delayed(const Duration(seconds: 5));
  }
});
