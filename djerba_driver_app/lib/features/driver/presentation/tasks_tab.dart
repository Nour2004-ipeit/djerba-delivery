import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../application/driver_service.dart';

class TasksTab extends StatefulWidget {
  const TasksTab({super.key});

  @override
  State<TasksTab> createState() => _TasksTabState();
}

class _TasksTabState extends State<TasksTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DriverService>().loadTasks();
    });
  }

  Widget _buildTaskCard(BuildContext context, {
    required String restaurantName,
    required String restaurantImage,
    required String itemsCount,
    required String estEarnings,
    required String pickupAddress,
    required String dropoffAddress,
    required String distance,
    required String time,
    required String timeAgo,
    required Map<String, dynamic> rawTask,
    bool isPriority = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isPriority ? DjerbaTheme.primaryColor : Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isPriority)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: DjerbaTheme.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bolt, color: DjerbaTheme.primaryColor, size: 14),
                  SizedBox(width: 4),
                  Text("High Priority", style: TextStyle(color: DjerbaTheme.primaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.network(
                  restaurantImage,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: DjerbaTheme.primaryLight,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Icon(Icons.storefront, color: DjerbaTheme.primaryColor),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurantName, 
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.inventory_2_outlined, size: 14, color: DjerbaTheme.textSecondary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            itemsCount, 
                            style: const TextStyle(color: DjerbaTheme.textSecondary, fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(estEarnings, style: const TextStyle(color: DjerbaTheme.primaryColor, fontWeight: FontWeight.w900, fontSize: 18)),
                  const Text("Est. earnings", style: TextStyle(color: DjerbaTheme.textSecondary, fontSize: 11)),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Timeline
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(color: DjerbaTheme.primaryLight, shape: BoxShape.circle),
                    child: Center(
                      child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: DjerbaTheme.primaryColor, shape: BoxShape.circle)),
                    ),
                  ),
                  Container(width: 2, height: 30, color: Colors.grey.withOpacity(0.3)),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(color: const Color(0xFFE0F2FE), shape: BoxShape.circle),
                    child: const Icon(Icons.near_me_outlined, color: Color(0xFF0284C7), size: 16),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("PICKUP", style: TextStyle(color: DjerbaTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    Text(pickupAddress, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 28),
                    const Text("DELIVER TO", style: TextStyle(color: DjerbaTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    Text(dropoffAddress, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 8),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 16, color: DjerbaTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text(distance, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 16),
                  const Icon(Icons.access_time, size: 16, color: DjerbaTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text(time, style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              Text(timeAgo, style: const TextStyle(color: DjerbaTheme.textSecondary, fontSize: 12)),
            ],
          ),
          
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text("Decline"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    final driverService = Provider.of<DriverService>(context, listen: false);
                    await driverService.acceptDelivery(rawTask);
                    if (context.mounted) {
                      if (driverService.hasActiveDelivery) {
                        context.go('/active');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Failed to accept task. Please try again."), backgroundColor: Colors.red),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DjerbaTheme.primaryLight,
                    foregroundColor: DjerbaTheme.primaryColor,
                  ),
                  child: const Text("Accept Task"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _resolveRestaurantImage(dynamic raw) {
    if (raw == null || raw.toString().isEmpty) {
      return "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&q=80&w=100";
    }
    String str = raw.toString();
    if (str.startsWith("http://") || str.startsWith("https://")) {
      if (kIsWeb && str.contains("10.0.2.2")) {
        return str.replaceAll("10.0.2.2", "localhost");
      }
      return str;
    }
    final host = kIsWeb ? "http://localhost:3000" : "http://10.0.2.2:3000";
    return "$host${str.startsWith('/') ? '' : '/'}$str";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Available Tasks", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
                      Text("5 delivery requests nearby", style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.filter_alt_outlined, size: 16, color: DjerbaTheme.textSecondary),
                        SizedBox(width: 6),
                        Text("Nearest First", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        SizedBox(width: 4),
                        Icon(Icons.keyboard_arrow_down, size: 16, color: DjerbaTheme.textSecondary),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Consumer<DriverService>(
                builder: (context, driverService, child) {
                  if (driverService.isLoadingTasks) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (driverService.availableTasks.isEmpty) {
                    return const Center(child: Text("Aucune commande disponible."));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(20),
                    physics: const BouncingScrollPhysics(),
                    itemCount: driverService.availableTasks.length,
                    itemBuilder: (context, index) {
                      final task = driverService.availableTasks[index];
                      return _buildTaskCard(
                        context,
                        rawTask: task,
                        restaurantName: task['restaurant'] != null ? task['restaurant']['name'] : "Restaurant Inconnu",
                        restaurantImage: _resolveRestaurantImage(task['restaurant']?['imageUrl']),
                        itemsCount: "Commande ${task['orderNumber']}",
                        estEarnings: "${task['deliveryFee']} TND",
                        pickupAddress: task['restaurant'] != null ? task['restaurant']['name'] : "Restaurant ${task['restaurantId']}",
                        dropoffAddress: task['deliveryAddress'] ?? 'Adresse inconnue',
                        distance: "1.8 km",
                        time: "12 min",
                        timeAgo: "Il y a 1 min",
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
