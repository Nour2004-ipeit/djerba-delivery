import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/theme.dart';
import '../application/driver_service.dart';
import '../../../core/services/routing_service.dart';

class ActiveTab extends StatefulWidget {
  const ActiveTab({super.key});

  @override
  State<ActiveTab> createState() => _ActiveTabState();
}

class _ActiveTabState extends State<ActiveTab> {
  List<LatLng> _routePoints = [];
  final RoutingService _routingService = RoutingService();
  double? _lastLat;
  double? _lastLng;

  final List<String> _steps = const [
    "Heading to Restaurant",
    "At Restaurant",
    "Order Picked Up",
    "On the Way",
    "Arrived at Place",
    "Delivered",
  ];

  final List<IconData> _stepIcons = const [
    Icons.navigation_outlined,
    Icons.storefront_outlined,
    Icons.inventory_2_outlined,
    Icons.local_shipping_outlined,
    Icons.flag_outlined,
    Icons.check_circle_outline,
  ];

  Widget _buildStepItem(int index, String title, IconData icon, int currentStep) {
    bool isCompleted = index < currentStep;
    bool isActive = index == currentStep;
    
    Color bgColor = Colors.transparent;
    Color textColor = DjerbaTheme.textSecondary;
    Color iconColor = DjerbaTheme.textSecondary;
    
    if (isActive) {
      bgColor = DjerbaTheme.primaryLight;
      textColor = DjerbaTheme.primaryColor;
      iconColor = DjerbaTheme.primaryColor;
    } else if (isCompleted) {
      bgColor = Colors.transparent;
      textColor = DjerbaTheme.primaryColor;
      iconColor = DjerbaTheme.primaryColor;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isActive ? DjerbaTheme.primaryColor : (isCompleted ? Colors.transparent : Colors.grey[100]),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isActive ? Icons.near_me : (isCompleted ? Icons.check : icon),
              color: isActive ? Colors.white : (isCompleted ? DjerbaTheme.primaryColor : Colors.grey[500]),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isActive ? FontWeight.bold : (isCompleted ? FontWeight.w500 : FontWeight.normal),
                color: textColor,
              ),
            ),
          ),
          if (isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: DjerbaTheme.primaryColor.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "Current",
                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DriverService>(
      builder: (context, driverService, child) {
        if (!driverService.hasActiveDelivery) {
          return const Scaffold(
            body: Center(
              child: Text("No active delivery.\nGo to Tasks to accept one.", textAlign: TextAlign.center, style: TextStyle(color: DjerbaTheme.textSecondary, fontSize: 16)),
            ),
          );
        }

        final currentStep = driverService.activeDeliveryStep;
        final nextStepText = currentStep < 5 ? _steps[currentStep + 1] : "Complete Delivery";
        final task = driverService.activeTask!;

        // Trigger route update if GPS changed
        final currentLat = driverService.currentLat;
        final currentLng = driverService.currentLng;
        if (currentLat != null && currentLng != null) {
          if (_lastLat != currentLat || _lastLng != currentLng) {
            _lastLat = currentLat;
            _lastLng = currentLng;
            
            // Fetch new route (Driver -> Restaurant -> Delivery)
            // For now we'll just use a mocked restaurant/delivery if not present in task, or parse from task
            final restLat = task['restaurantLat'] ?? 33.8200;
            final restLng = task['restaurantLng'] ?? 10.8600;
            final destLat = task['deliveryLat'] ?? 33.8700;
            final destLng = task['deliveryLng'] ?? 10.9800;

            _routingService.getMultiPointRoute([
              LatLng(currentLat, currentLng),
              LatLng(restLat, restLng),
              LatLng(destLat, destLng)
            ]).then((points) {
              if (mounted) {
                setState(() {
                  _routePoints = points;
                });
              }
            });
          }
        }

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                // Top Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Active Delivery", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                          Text("Commande ${task['orderNumber']}", style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          border: Border.all(color: DjerbaTheme.dangerLight),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: DjerbaTheme.danger, size: 16),
                            const SizedBox(width: 6),
                            Text("Report Issue", style: TextStyle(color: DjerbaTheme.danger, fontWeight: FontWeight.bold, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFEEEEEE)),
                
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      // 6-Step Timeline Card
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.withOpacity(0.2)),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          children: List.generate(_steps.length, (index) {
                            return _buildStepItem(index, _steps[index], _stepIcons[index], currentStep);
                          }),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Restaurant Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.withOpacity(0.2)),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: const DecorationImage(
                                  image: NetworkImage('https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&q=80&w=200'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Restaurant ${task['restaurantId']}", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.location_on_outlined, color: Colors.grey[500], size: 14),
                                      const SizedBox(width: 4),
                                      Expanded(child: Text("Djerba Midoun", style: TextStyle(color: Colors.grey[600], fontSize: 12), overflow: TextOverflow.ellipsis)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.withOpacity(0.3)),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.phone_outlined, size: 20),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Customer Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.withOpacity(0.2)),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: const DecorationImage(
                                  image: NetworkImage('https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=200'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Client Djerba", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                                  const SizedBox(height: 4),
                                  Text("Customer", style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.withOpacity(0.3)),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.phone_outlined, size: 20),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.withOpacity(0.3)),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.chat_bubble_outline, size: 20),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Order Details Section
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.withOpacity(0.2)),
                          borderRadius: BorderRadius.circular(24),
                          color: Colors.white,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Map Preview
                            Container(
                              height: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              clipBehavior: Clip.hardEdge,
                              child: FlutterMap(
                                options: MapOptions(
                                  initialCenter: const LatLng(33.8830, 10.8600),
                                  initialZoom: 13.5,
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate: 'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
                                    userAgentPackageName: 'com.djerba.delivery',
                                  ),
                                  PolylineLayer(
                                    polylines: <Polyline>[
                                      if (_routePoints.isNotEmpty)
                                        Polyline(
                                          points: _routePoints,
                                          strokeWidth: 5.0,
                                          color: DjerbaTheme.primaryColor,
                                        )
                                      else
                                        Polyline(
                                          points: [
                                            LatLng(task['restaurantLat'] ?? 33.8200, task['restaurantLng'] ?? 10.8600),
                                            LatLng(task['deliveryLat'] ?? 33.8700, task['deliveryLng'] ?? 10.9800),
                                          ],
                                          strokeWidth: 4.0,
                                          color: DjerbaTheme.primaryColor.withOpacity(0.5),
                                        ),
                                    ],
                                  ),
                                  MarkerLayer(
                                    markers: [
                                      Marker(
                                        point: LatLng(task['restaurantLat'] ?? 33.8200, task['restaurantLng'] ?? 10.8600),
                                        width: 32,
                                        height: 52,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 32,
                                              height: 32,
                                              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: DjerbaTheme.primaryColor, width: 2.5), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)]),
                                              child: const Center(child: Icon(Icons.storefront, color: DjerbaTheme.primaryColor, size: 18)),
                                            ),
                                            Container(width: 3, height: 16, color: DjerbaTheme.primaryColor),
                                          ],
                                        ),
                                      ),
                                      Marker(
                                        point: LatLng(task['deliveryLat'] ?? 33.8700, task['deliveryLng'] ?? 10.9800),
                                        width: 32,
                                        height: 52,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: const BorderRadius.only(topRight: Radius.circular(8), bottomRight: Radius.circular(8), topLeft: Radius.circular(2), bottomLeft: Radius.circular(2)),
                                                border: Border.all(color: DjerbaTheme.primaryColor, width: 2.5),
                                                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                                              ),
                                              child: const Icon(Icons.flag, color: DjerbaTheme.primaryColor, size: 16),
                                            ),
                                            Container(margin: const EdgeInsets.only(left: 2), width: 3, height: 16, color: DjerbaTheme.primaryColor),
                                          ],
                                        ),
                                      ),
                                      if (driverService.currentLat != null && driverService.currentLng != null)
                                        Marker(
                                          point: LatLng(driverService.currentLat!, driverService.currentLng!),
                                          width: 50,
                                          height: 50,
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              const Icon(Icons.pedal_bike, size: 40, color: DjerbaTheme.primaryColor),
                                              Positioned(
                                                left: 8,
                                                top: 8,
                                                child: Container(
                                                  width: 14, height: 14,
                                                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2), border: Border.all(color: DjerbaTheme.primaryColor, width: 1.5)),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Deliver To
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: DjerbaTheme.primaryLight,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.near_me_outlined, color: DjerbaTheme.primaryColor, size: 16),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text("DELIVER TO", style: TextStyle(color: DjerbaTheme.textSecondary, fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      Text(task['deliveryAddress'] ?? 'Unknown Address', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // Instructions
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8F9FA),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("INSTRUCTIONS", style: TextStyle(color: DjerbaTheme.textSecondary, fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  const Text("Please leave at the door. Ring doorbell twice.", style: TextStyle(color: DjerbaTheme.textPrimary, fontSize: 14)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Order Items
                            const Text("Order Items", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Truffle Mushroom Pasta", style: TextStyle(color: DjerbaTheme.textPrimary)),
                                Text("x2", style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Tiramisu", style: TextStyle(color: DjerbaTheme.textPrimary)),
                                Text("x1", style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.bold)),
                              ],
                            ),
                            
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Divider(),
                            ),
                            
                            // Meta Info
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined, color: DjerbaTheme.textSecondary, size: 16),
                                const SizedBox(width: 4),
                                const Text("2.3 km", style: TextStyle(color: DjerbaTheme.textSecondary, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 16),
                                const Icon(Icons.access_time, color: DjerbaTheme.textSecondary, size: 16),
                                const SizedBox(width: 4),
                                const Text("15 min", style: TextStyle(color: DjerbaTheme.textSecondary, fontWeight: FontWeight.bold)),
                                const Spacer(),
                                Text("${task['deliveryFee']} TND", style: const TextStyle(color: DjerbaTheme.primaryColor, fontWeight: FontWeight.w900, fontSize: 20)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 120), // Padding for sticky bottom button
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Sticky Bottom Action Button
          bottomSheet: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
            ),
            child: SafeArea(
              child: ElevatedButton(
                onPressed: () async {
                  await driverService.advanceDeliveryStep();
                  if (!driverService.hasActiveDelivery && context.mounted) {
                    // Navigating back to tasks if delivery completed
                    context.go('/tasks');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: DjerbaTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.keyboard_arrow_up, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      "Mark as: $nextStepText",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
