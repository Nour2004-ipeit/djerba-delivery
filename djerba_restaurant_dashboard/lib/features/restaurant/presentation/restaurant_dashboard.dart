import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';

class RestaurantDashboard extends StatefulWidget {
  const RestaurantDashboard({super.key});

  @override
  State<RestaurantDashboard> createState() => _RestaurantDashboardState();
}

class _RestaurantDashboardState extends State<RestaurantDashboard> {
  bool _isAcceptingOrders = true;
  int _navIndex = 0;

  Widget _buildStatCard(String title, String value, String unit, IconData icon, Color color, Color bgColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: DjerbaTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: DjerbaTheme.textPrimary,
                  ),
                ),
                if (unit.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  Text(
                    unit,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: DjerbaTheme.textPrimary,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard({
    required String statusText,
    required String statusIcon,
    required Color statusColor,
    required Color statusBgColor,
    required String orderId,
    required String timeAgo,
    required String price,
    required Widget content,
    required Widget actions,
    Color borderColor = Colors.transparent,
    Color cardBgColor = Colors.white,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor == Colors.transparent ? Colors.grey.withOpacity(0.1) : borderColor, width: borderColor == Colors.transparent ? 1 : 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "$statusText $statusIcon",
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    orderId,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: DjerbaTheme.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    timeAgo,
                    style: const TextStyle(fontSize: 12, color: DjerbaTheme.textSecondary),
                  ),
                ],
              ),
              if (price.isNotEmpty)
                Text(
                  price,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: DjerbaTheme.primaryColor),
                ),
            ],
          ),
          const SizedBox(height: 16),
          content,
          if (actions != const SizedBox.shrink()) ...[
            const SizedBox(height: 16),
            actions,
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF9F5), // Light warm background
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/roles'),
        ),
        title: Column(
          children: [
            const Text("Dar Djerba", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _isAcceptingOrders ? DjerbaTheme.success : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _isAcceptingOrders ? "Accepting Orders" : "Offline",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _isAcceptingOrders ? DjerbaTheme.success : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          Switch(
            value: _isAcceptingOrders,
            onChanged: (val) {
              setState(() {
                _isAcceptingOrders = val;
              });
            },
            activeColor: DjerbaTheme.primaryColor,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildStatCard(
                    "Orders Today",
                    "42",
                    "",
                    Icons.receipt_long,
                    DjerbaTheme.primaryColor,
                    DjerbaTheme.primaryLight,
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    "Revenue",
                    "540",
                    "DT",
                    Icons.payments,
                    DjerbaTheme.success,
                    DjerbaTheme.successLight,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Text("Active Orders", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                  const SizedBox(width: 8),
                  Text("(3)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: DjerbaTheme.textSecondary)),
                ],
              ),
              const SizedBox(height: 16),
              
              // New Order
              _buildOrderCard(
                statusText: "NEW",
                statusIcon: "⚡",
                statusColor: DjerbaTheme.primaryColor,
                statusBgColor: DjerbaTheme.primaryLight,
                orderId: "#ORD-1042",
                timeAgo: "2 min ago • 3 items",
                price: "45.00 DT",
                borderColor: DjerbaTheme.primaryColor.withOpacity(0.3),
                content: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F4EF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [Text("2x Couscous au Poisson"), Text("39.00", style: TextStyle(fontWeight: FontWeight.bold))],
                      ),
                      SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [Text("1x Salade Mechouia"), Text("6.00", style: TextStyle(fontWeight: FontWeight.bold))],
                      ),
                    ],
                  ),
                ),
                actions: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          side: BorderSide(color: Colors.grey.withOpacity(0.2)),
                        ),
                        child: const Text("Decline", style: TextStyle(color: DjerbaTheme.textSecondary, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: DjerbaTheme.primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: const Text("Accept Order", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),

              // Preparing Order
              _buildOrderCard(
                statusText: "PREPARING",
                statusIcon: "🍳",
                statusColor: DjerbaTheme.primaryColor,
                statusBgColor: DjerbaTheme.primaryLight,
                orderId: "#ORD-1041",
                timeAgo: "Accepted 12 min ago",
                price: "",
                content: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Prep time", style: TextStyle(fontSize: 12, color: DjerbaTheme.textSecondary)),
                        Text("8 / 15 min", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: DjerbaTheme.textPrimary)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: const LinearProgressIndicator(
                        value: 0.53,
                        backgroundColor: DjerbaTheme.primaryLight,
                        color: DjerbaTheme.primaryColor,
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
                actions: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: DjerbaTheme.success,
                    minimumSize: const Size(double.infinity, 0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check, size: 16),
                      SizedBox(width: 8),
                      Text("Mark as Ready", style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 40), // Padding for bottom nav
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _navIndex,
        onTap: (index) {
          setState(() {
            _navIndex = index;
          });
        },
        items: [
          BottomNavBarItem(icon: Icons.room_service, label: "Orders"),
          BottomNavBarItem(icon: Icons.menu_book, label: "Menu"),
          BottomNavBarItem(icon: Icons.pie_chart, label: "Analytics"),
          BottomNavBarItem(icon: Icons.person, label: "Profile"),
        ],
      ),
    );
  }
}
