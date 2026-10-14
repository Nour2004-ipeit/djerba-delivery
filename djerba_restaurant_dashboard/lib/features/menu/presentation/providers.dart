import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/menu_api.dart';

final menuApiProvider = Provider((ref) => MenuApi());

final myRestaurantIdProvider = FutureProvider<String?>((ref) async {
  final api = ref.watch(menuApiProvider);
  return api.getMyRestaurantId();
});

final myRestaurantNameProvider = FutureProvider<String?>((ref) async {
  final api = ref.watch(menuApiProvider);
  return api.getMyRestaurantName();
});

final myRestaurantImageProvider = FutureProvider<String?>((ref) async {
  final api = ref.watch(menuApiProvider);
  return api.getMyRestaurantImage();
});

final menuProductsProvider = FutureProvider<List<ProductModel>>((ref) async {
  final api = ref.watch(menuApiProvider);
  final restaurantId = await ref.watch(myRestaurantIdProvider.future);
  if (restaurantId == null) return [];
  return api.getProducts(restaurantId);
});
