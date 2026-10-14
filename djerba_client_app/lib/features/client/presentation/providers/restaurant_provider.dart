import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models.dart';
import '../../data/restaurant_api.dart';

final restaurantApiProvider = Provider((ref) => RestaurantApi());

final restaurantsProvider = FutureProvider<List<RestaurantModel>>((ref) async {
  final api = ref.watch(restaurantApiProvider);
  return await api.getRestaurants();
});

final restaurantProductsProvider = FutureProvider.family<List<ProductModel>, String>((ref, restaurantId) async {
  final api = ref.watch(restaurantApiProvider);
  return await api.getRestaurantProducts(restaurantId);
});

final productSearchProvider = FutureProvider.family<List<ProductModel>, String>((ref, query) async {
  if (query.isEmpty) return [];
  final api = ref.watch(restaurantApiProvider);
  return await api.searchProducts(query);
});
