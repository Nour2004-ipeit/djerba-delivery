import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../../../core/providers/admin_provider.dart';

class OverviewPage extends ConsumerWidget {
  const OverviewPage({super.key});

  Widget _buildStatCard(String title, String value, String trend, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: trend.startsWith('+') ? DjerbaTheme.successLight : DjerbaTheme.dangerLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    trend,
                    style: TextStyle(color: trend.startsWith('+') ? DjerbaTheme.success : DjerbaTheme.danger, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              value,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(color: DjerbaTheme.textSecondary, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsProvider);
    final ordersAsync = ref.watch(ordersProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Platform Overview", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
          const Text("Welcome back! Here is what's happening across Djerba Delivery.", style: TextStyle(color: DjerbaTheme.textSecondary, fontSize: 16)),
          const SizedBox(height: 32),
          
          statsAsync.when(
            data: (stats) => Row(
              children: [
                _buildStatCard("Total Revenue", "${stats['totalRevenue']} TND", "", Icons.attach_money, DjerbaTheme.primaryColor),
                const SizedBox(width: 24),
                _buildStatCard("Total Orders", "${stats['totalOrders']}", "", Icons.shopping_bag, DjerbaTheme.warning),
                const SizedBox(width: 24),
                _buildStatCard("Active Drivers", "${stats['activeDrivers']}", "", Icons.two_wheeler, DjerbaTheme.success),
                const SizedBox(width: 24),
                _buildStatCard("Total Users", "${stats['totalUsers']}", "", Icons.people, Colors.purple),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
          
          const SizedBox(height: 32),
          
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  height: 400,
                  padding: const EdgeInsets.all(24),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Revenue Over Time", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 24),
                      Expanded(
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(show: false),
                            titlesData: FlTitlesData(show: false),
                            borderData: FlBorderData(show: false),
                            minX: 0,
                            maxX: 7,
                            minY: 0,
                            maxY: 6,
                            lineBarsData: [
                              LineChartBarData(
                                spots: const [
                                  FlSpot(0, 3),
                                  FlSpot(1, 1),
                                  FlSpot(2, 4),
                                  FlSpot(3, 2),
                                  FlSpot(4, 5),
                                  FlSpot(5, 3),
                                  FlSpot(6, 4),
                                  FlSpot(7, 6),
                                ],
                                isCurved: true,
                                color: DjerbaTheme.primaryColor,
                                barWidth: 4,
                                isStrokeCapRound: true,
                                dotData: FlDotData(show: false),
                                belowBarData: BarAreaData(show: true, color: DjerbaTheme.primaryColor.withOpacity(0.1)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 1,
                child: Container(
                  height: 400,
                  padding: const EdgeInsets.all(24),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Recent Activity", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 24),
                      Expanded(
                        child: ordersAsync.when(
                          data: (orders) {
                            if (orders.isEmpty) {
                               return const Center(child: Text("No recent activity", style: TextStyle(color: DjerbaTheme.textSecondary)));
                            }
                            final recentOrders = List.from(orders)..sort((a, b) {
                              final dateA = a['createdAt'] ?? a['created_at'];
                              final dateB = b['createdAt'] ?? b['created_at'];
                              return DateTime.parse(dateB).compareTo(DateTime.parse(dateA));
                            });
                            final topRecent = recentOrders.take(4).toList();
                            
                            return ListView.builder(
                              itemCount: topRecent.length,
                              itemBuilder: (context, index) {
                                final order = topRecent[index];
                                final isDelivered = order['status'] == 'delivered';
                                final orderNumber = order['orderNumber'] ?? order['order_number'] ?? 'CMD-???';
                                final totalAmount = order['totalAmount'] ?? order['total_amount'] ?? '0';
                                return _buildActivityItem(
                                  isDelivered ? "Order Delivered" : "New Order Placed", 
                                  "$orderNumber - $totalAmount TND", 
                                  isDelivered ? "Delivered" : "Just now", 
                                  isDelivered ? Icons.check_circle : Icons.receipt_long, 
                                  isDelivered ? DjerbaTheme.success : DjerbaTheme.warning
                                );
                              }
                            );
                          },
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (e, s) => const Center(child: Text("Error loading activity")),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String subtitle, String time, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(subtitle, style: const TextStyle(color: DjerbaTheme.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Text(time, style: const TextStyle(color: DjerbaTheme.textTertiary, fontSize: 12)),
        ],
      ),
    );
  }
}
