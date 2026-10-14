import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../application/driver_service.dart';
import '../../auth/presentation/auth_provider.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {

  Widget _buildNotificationsModal(BuildContext context, DriverService driverService) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Notifications", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
              if (driverService.notifications.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: DjerbaTheme.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text("${driverService.notifications.length} New", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 24),
          if (driverService.notifications.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: Text("Aucune nouvelle notification.", style: TextStyle(color: DjerbaTheme.textSecondary))),
            )
          else
            ...driverService.notifications.map((notif) => Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: DjerbaTheme.primaryLight, shape: BoxShape.circle),
                    child: const Icon(Icons.bolt, color: DjerbaTheme.primaryColor),
                  ),
                  title: Text(notif['title'] ?? 'Notification', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(notif['body'] ?? ''),
                  trailing: Text(notif['time'] ?? 'Just now', style: const TextStyle(color: DjerbaTheme.textSecondary, fontSize: 12)),
                ),
                const Divider(),
              ],
            )).toList(),
        ],
      ),
    );
  }

  Widget _buildPerformanceCard({
    required IconData icon,
    required Color iconColor,
    required String topRightText,
    required Color topRightColor,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              Text(
                topRightText,
                style: TextStyle(color: topRightColor, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          Text(label, style: const TextStyle(color: DjerbaTheme.textSecondary, fontSize: 14)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final driverService = Provider.of<DriverService>(context);
    final userName = 'Driver';
    final stats = driverService.stats ?? {};
    final earnings = (stats['todayEarnings'] as num?)?.toDouble() ?? 0.0;
    final deliveries = (stats['todayDeliveries'] as num?)?.toInt() ?? 0;
    final activeHours = (stats['activeHours'] as num?)?.toDouble() ?? 0.0;
    final rating = (stats['rating'] as num?)?.toDouble() ?? 0.0;
    final dailyGoal = 150.0;
    final double progress = (earnings / dailyGoal).clamp(0.0, 1.0);
    final double remaining = (dailyGoal - earnings).clamp(0.0, double.infinity);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Dashboard", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
                      Text("Welcome back, $userName", style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                    ],
                  ),
                  Row(
                    children: [
                      // Notification Bell
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.white,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                            ),
                            builder: (context) => _buildNotificationsModal(context, driverService),
                          );
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.withOpacity(0.2)),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const Icon(Icons.notifications_none, color: DjerbaTheme.textPrimary),
                              if (driverService.notifications.isNotEmpty)
                                Positioned(
                                  right: 8,
                                  top: 8,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: DjerbaTheme.primaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text("${driverService.notifications.length}", style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Online Toggle
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.grey.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: driverService.isOnline ? DjerbaTheme.primaryColor : Colors.grey,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text("Online", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(width: 8),
                            SizedBox(
                              height: 24,
                              width: 36,
                              child: Switch(
                                value: driverService.isOnline,
                                onChanged: (val) => driverService.toggleOnline(),
                                activeColor: DjerbaTheme.primaryColor,
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              const Text("Today's Performance", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
              const SizedBox(height: 16),
              
              // Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  _buildPerformanceCard(
                    icon: Icons.attach_money,
                    iconColor: DjerbaTheme.primaryColor,
                    topRightText: "",
                    topRightColor: DjerbaTheme.primaryColor,
                    value: "${earnings.toStringAsFixed(2)} TND",
                    label: "Earnings",
                  ),
                  _buildPerformanceCard(
                    icon: Icons.inventory_2_outlined,
                    iconColor: const Color(0xFF00A8C6),
                    topRightText: "",
                    topRightColor: const Color(0xFF00A8C6),
                    value: "$deliveries",
                    label: "Deliveries",
                  ),
                  _buildPerformanceCard(
                    icon: Icons.access_time,
                    iconColor: const Color(0xFF6B9B7E),
                    topRightText: "Active",
                    topRightColor: const Color(0xFF6B9B7E),
                    value: "${activeHours}h",
                    label: "Hours",
                  ),
                  _buildPerformanceCard(
                    icon: Icons.military_tech_outlined,
                    iconColor: const Color(0xFFF59E0B),
                    topRightText: "Excellent",
                    topRightColor: const Color(0xFFF59E0B),
                    value: "$rating",
                    label: "Rating",
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Daily Goal Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: DjerbaTheme.primaryLight,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: DjerbaTheme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.track_changes, color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Daily Goal", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                              Text("${earnings.toStringAsFixed(2)} of $dailyGoal TND", style: const TextStyle(color: DjerbaTheme.textSecondary, fontSize: 14)),
                            ],
                          ),
                        ),
                        Text("${(progress * 100).toInt()}%", style: const TextStyle(color: DjerbaTheme.primaryColor, fontWeight: FontWeight.w900, fontSize: 24)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white.withOpacity(0.5),
                        valueColor: const AlwaysStoppedAnimation<Color>(DjerbaTheme.primaryColor),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (remaining > 0)
                      Text("${remaining.toStringAsFixed(2)} TND more to reach your daily goal", style: const TextStyle(color: DjerbaTheme.textSecondary, fontSize: 12))
                    else
                      const Text("Goal reached! Great job!", style: TextStyle(color: DjerbaTheme.success, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.bolt, color: DjerbaTheme.primaryColor),
                      SizedBox(width: 8),
                      Text("New Delivery Requests", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                    ],
                  ),
                  Text("View All >", style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.bold)),
                ],
              ),
              
              const SizedBox(height: 16),
              // Show first available task if exists
              if (driverService.availableTasks.isNotEmpty)
                Builder(
                  builder: (context) {
                    final task = driverService.availableTasks.first;
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: DjerbaTheme.primaryColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
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
                                Text("Live Request", style: TextStyle(color: DjerbaTheme.primaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: Image.network(
                                  'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&q=80&w=100',
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Restaurant ${task['restaurantId']}", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                                    Text("Commande ${task['orderNumber']}", style: const TextStyle(color: DjerbaTheme.textSecondary)),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on_outlined, size: 16, color: DjerbaTheme.textSecondary),
                                        const SizedBox(width: 4),
                                        const Text("2.3 km", style: TextStyle(color: DjerbaTheme.textSecondary)),
                                        const SizedBox(width: 12),
                                        const Icon(Icons.access_time, size: 16, color: DjerbaTheme.textSecondary),
                                        const SizedBox(width: 4),
                                        const Text("15 min", style: TextStyle(color: DjerbaTheme.textSecondary)),
                                        const SizedBox(width: 12),
                                        Text("${task['deliveryFee']} TND", style: const TextStyle(color: DjerbaTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
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
                                    await driverService.acceptDelivery(task);
                                    if (context.mounted) context.go('/active');
                                  },
                                  child: const Text("Accept"),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }
                )
              else 
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: Text("Aucune nouvelle commande pour le moment.", style: TextStyle(color: DjerbaTheme.textSecondary))),
                ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
