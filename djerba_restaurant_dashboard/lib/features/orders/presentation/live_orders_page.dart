import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../data/models.dart';
import 'providers.dart';

class LiveOrdersPage extends ConsumerStatefulWidget {
  const LiveOrdersPage({super.key});

  @override
  ConsumerState<LiveOrdersPage> createState() => _LiveOrdersPageState();
}

class _LiveOrdersPageState extends ConsumerState<LiveOrdersPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Live Orders", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
              ElevatedButton.icon(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: DjerbaTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                icon: const Icon(Icons.add, size: 20),
                label: const Text("New Manual Order", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ref.watch(ordersProvider).when(
              data: (orders) {
                final pendingOrders = orders.where((o) => o.status == 'pending' || o.status == 'accepted').toList();
                final preparingOrders = orders.where((o) => o.status == 'preparing').toList();
                final readyOrders = orders.where((o) => o.status == 'ready_for_pickup').toList();

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildKanbanColumn("New Requests", pendingOrders, DjerbaTheme.primaryColor, 'preparing'),
                    const SizedBox(width: 24),
                    _buildKanbanColumn("Preparing", preparingOrders, DjerbaTheme.warning, 'ready_for_pickup'),
                    const SizedBox(width: 24),
                    _buildKanbanColumn("Ready for Driver", readyOrders, DjerbaTheme.success, 'picked_up'),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Erreur: $error')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKanbanColumn(String title, List<OrderModel> orders, Color headerColor, String nextStatus) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: headerColor.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                border: Border(bottom: BorderSide(color: headerColor.withOpacity(0.2), width: 2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: headerColor)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: Text(orders.length.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  return _buildOrderCard(orders[index], nextStatus);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order, String nextStatus) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(order.orderNumber, style: TextStyle(fontWeight: FontWeight.w900, color: Colors.blueGrey[800], fontSize: 16)),
              Text(order.createdAt.toLocal().toString().split('.')[0], style: TextStyle(color: Colors.grey[500], fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          Text(order.clientName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueGrey[700])),
          if (order.itemsSummary.isNotEmpty && order.itemsSummary != 'Produits...') 
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(order.itemsSummary, style: const TextStyle(color: DjerbaTheme.textSecondary, height: 1.5)),
            )
          else
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text("Aucun article spécifié", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
            ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${order.totalAmount} TND", style: const TextStyle(fontWeight: FontWeight.w900, color: DjerbaTheme.primaryColor, fontSize: 16)),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await ref.read(ordersApiProvider).updateOrderStatus(order.id, nextStatus);
                    ref.invalidate(ordersProvider);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: $e")));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: DjerbaTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  minimumSize: Size.zero,
                ),
                child: const Text("Next Step"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
