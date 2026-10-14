import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/admin/data/admin_api.dart';

final adminApiProvider = Provider((ref) => AdminApi());

final statsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.watch(adminApiProvider);
  return await api.fetchStats();
});

final usersProvider = FutureProvider<List<dynamic>>((ref) async {
  final api = ref.watch(adminApiProvider);
  return await api.fetchUsers();
});

final ordersProvider = StreamProvider.autoDispose<List<dynamic>>((ref) async* {
  final api = ref.watch(adminApiProvider);
  while (true) {
    yield await api.fetchOrders();
    await Future.delayed(const Duration(seconds: 5));
  }
});
