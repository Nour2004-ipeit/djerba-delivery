import 'package:flutter/material.dart';
import '../../../core/theme.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/admin_provider.dart';

class TrackingPage extends ConsumerWidget {
  const TrackingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersProvider);
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Live Delivery Tracking", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: DjerbaTheme.successLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.circle, color: DjerbaTheme.success, size: 12),
                    const SizedBox(width: 8),
                    ordersAsync.when(
                      data: (orders) {
                        final activeCount = orders.where((o) => ['accepted', 'preparing', 'ready', 'picked_up', 'arrived_at_place'].contains(o['status'])).length;
                        return Text("$activeCount Active Deliveries", style: const TextStyle(color: DjerbaTheme.success, fontWeight: FontWeight.bold));
                      },
                      loading: () => const Text("...", style: TextStyle(color: DjerbaTheme.success, fontWeight: FontWeight.bold)),
                      error: (e, s) => const Text("Error", style: TextStyle(color: DjerbaTheme.danger, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Row(
              children: [
                // Active Deliveries List
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("In Progress", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              Icon(Icons.filter_list, color: DjerbaTheme.textSecondary),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        Expanded(
                          child: ordersAsync.when(
                            data: (orders) {
                              final activeOrders = orders.where((o) => ['accepted', 'preparing', 'ready', 'picked_up', 'arrived_at_place'].contains(o['status'])).toList();
                              if (activeOrders.isEmpty) {
                                return const Center(child: Text("No active deliveries", style: TextStyle(color: DjerbaTheme.textSecondary)));
                              }
                              return ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: activeOrders.length,
                                itemBuilder: (context, index) {
                                  final order = activeOrders[index];
                                  String statusText = "";
                                  switch (order['status']) {
                                    case 'accepted': statusText = "Heading to Restaurant"; break;
                                    case 'preparing': statusText = "Preparing Food"; break;
                                    case 'ready': statusText = "Ready for Pickup"; break;
                                    case 'picked_up': statusText = "On the Way"; break;
                                    case 'arrived_at_place': statusText = "Arrived at Place"; break;
                                  }
                                  return _buildDeliveryCard(
                                    order['order_number'] ?? "#ORD", 
                                    order['driver']?['name'] ?? "Assigning...", 
                                    order['restaurant']?['name'] ?? "Restaurant", 
                                    statusText
                                  );
                                }
                              );
                            },
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (e, s) => const Center(child: Text("Error loading active deliveries")),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                // Map Placeholder
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: DjerbaTheme.primaryLight,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Image.network(
                            "https://images.unsplash.com/photo-1524661135-423995f22d0b?auto=format&fit=crop&q=80&w=800",
                            fit: BoxFit.cover,
                            opacity: const AlwaysStoppedAnimation(0.5),
                          ),
                        ),
                        const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.map, size: 64, color: DjerbaTheme.primaryColor),
                              SizedBox(height: 16),
                              Text("Live Map View", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: DjerbaTheme.darkBlue)),
                              SizedBox(height: 8),
                              Text("Google Maps integration placeholder", style: TextStyle(color: DjerbaTheme.darkBlue)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryCard(String orderId, String driver, String restaurant, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DjerbaTheme.backgroundLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(orderId, style: const TextStyle(fontWeight: FontWeight.bold, color: DjerbaTheme.primaryColor)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: DjerbaTheme.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(status, style: const TextStyle(color: DjerbaTheme.warning, fontWeight: FontWeight.bold, fontSize: 10)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.two_wheeler, size: 16, color: DjerbaTheme.textSecondary),
              const SizedBox(width: 8),
              Text(driver, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.storefront, size: 16, color: DjerbaTheme.textSecondary),
              const SizedBox(width: 8),
              Text(restaurant, style: const TextStyle(color: DjerbaTheme.textSecondary, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
