import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../core/network/dio_client.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../menu/presentation/providers.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  List<dynamic> _orders = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _fetchOrders());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchOrders() async {
    try {
      final response = await DioClient().dio.get('/orders');
      if (mounted) {
        setState(() {
          _orders = response.data;
        });
      }
    } catch (e) {
      print('Error fetching orders: $e');
    }
  }

  Future<void> _updateStatus(String id, String status) async {
    try {
      await DioClient().dio.put('/orders/$id/status', data: {'status': status});
      _fetchOrders();
    } catch (e) {
      print('Error updating status: $e');
    }
  }

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
                    color: DjerbaTheme.successLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    trend,
                    style: const TextStyle(color: DjerbaTheme.success, fontWeight: FontWeight.bold, fontSize: 12),
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
  Widget build(BuildContext context) {
    final restaurantNameAsync = ref.watch(myRestaurantNameProvider);
    final restaurantName = restaurantNameAsync.value ?? 'votre restaurant';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Overview", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
          Text("Here's what's happening at $restaurantName today.", style: const TextStyle(color: DjerbaTheme.textSecondary, fontSize: 16)),
          const SizedBox(height: 32),
          
          Row(
            children: [
              _buildStatCard("Today's Revenue", "\$1,248.50", "+12.5%", Icons.attach_money, DjerbaTheme.primaryColor),
              const SizedBox(width: 24),
              _buildStatCard("Active Orders", "12", "+2.4%", Icons.local_dining, DjerbaTheme.warning),
              const SizedBox(width: 24),
              _buildStatCard("Completed", "86", "+18.2%", Icons.check_circle_outline, DjerbaTheme.success),
              const SizedBox(width: 24),
              _buildStatCard("Average Rating", "4.8", "+0.2", Icons.star_border, Colors.purple),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Recent Orders Table
          Container(
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
                    const Text("Recent Orders", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    TextButton(
                      onPressed: () {},
                      child: const Text("View All"),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: MediaQuery.of(context).size.width - 64 - 250, // Screen width minus padding and sidebar
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingTextStyle: const TextStyle(color: DjerbaTheme.textSecondary, fontWeight: FontWeight.bold),
                      dataRowMinHeight: 60,
                      dataRowMaxHeight: 60,
                      columns: const [
                        DataColumn(label: Text('Order ID')),
                        DataColumn(label: Text('Customer')),
                        DataColumn(label: Text('Items')),
                        DataColumn(label: Text('Total')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Action')),
                      ],
                      rows: _orders.map((o) => _buildDataRow(o)).toList(),
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

  DataRow _buildDataRow(dynamic order) {
    final id = order['orderNumber'] ?? order['id'];
    final status = order['status'] ?? 'unknown';
    final total = '${order['totalAmount'] ?? 0} TND';
    
    Color statusColor = DjerbaTheme.textTertiary;
    if (status == 'pending') statusColor = DjerbaTheme.warning;
    if (status == 'preparing') statusColor = Colors.orange;
    if (status == 'ready_for_pickup') statusColor = DjerbaTheme.success;
    if (status == 'delivering') statusColor = DjerbaTheme.primaryColor;

    return DataRow(
      cells: [
        DataCell(Text(id, style: const TextStyle(fontWeight: FontWeight.bold))),
        DataCell(Text('Client #${(order['clientId'] ?? '').toString().substring(0,4)}..._')),
        DataCell(Text('...', style: const TextStyle(color: DjerbaTheme.textSecondary))),
        DataCell(Text(total, style: const TextStyle(fontWeight: FontWeight.bold))),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status.toUpperCase(),
              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ),
        DataCell(
          status == 'pending' || status == 'preparing'
            ? ElevatedButton(
                onPressed: () => _updateStatus(order['id'], status == 'pending' ? 'preparing' : 'ready_for_pickup'),
                child: Text(status == 'pending' ? 'Accept & Prepare' : 'Mark Ready'),
              )
            : const SizedBox(),
        ),
      ],
    );
  }
}
