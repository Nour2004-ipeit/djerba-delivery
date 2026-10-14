import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import 'widgets/home_tab.dart';
import 'widgets/users_tab.dart';
import 'widgets/partners_tab.dart';
import 'widgets/settings_tab.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _navIndex = 0;

  Widget _buildListItem(String title, String subtitle, String trailing, Color statusColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: DjerbaTheme.textSecondary, fontSize: 13)),
              ],
            ),
          ),
          Text(trailing, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DjerbaTheme.backgroundLight,
      appBar: _navIndex == 0 ? AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/roles'),
        ),
        title: const Text("Supervision", style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ) : null,
      body: _buildBody(),
      floatingActionButton: _navIndex == 3 
          ? FloatingActionButton.extended(
              onPressed: () => _showAddDiscountDialog(context),
              backgroundColor: DjerbaTheme.primaryColor,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text("Add Discount", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ) 
          : null,
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _navIndex,
        onTap: (index) {
          setState(() {
            _navIndex = index;
          });
        },
        items: [
          BottomNavBarItem(icon: Icons.dashboard, label: "Home"),
          BottomNavBarItem(icon: Icons.people, label: "Users"),
          BottomNavBarItem(icon: Icons.store, label: "Partners"),
          BottomNavBarItem(icon: Icons.local_offer, label: "Discounts"),
          BottomNavBarItem(icon: Icons.settings, label: "Settings"),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_navIndex) {
      case 0: return const HomeTab();
      case 1: return const UsersTab();
      case 2: return const PartnersTab();
      case 3: return _buildDiscountsTab();
      case 4: return const SettingsTab();
      default: return const SizedBox();
    }
  }

  Widget _buildDiscountsTab() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Discounts & Promos", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildListItem("SUMMER2026", "20% off all orders • Expires Aug 30", "Active", DjerbaTheme.success),
                  const Divider(),
                  _buildListItem("WELCOME5", "5 DT off first order • No expiry", "Active", DjerbaTheme.success),
                  const Divider(),
                  _buildListItem("FLASH50", "50% off • Expired", "Expired", DjerbaTheme.danger),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDiscountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Create New Discount",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: DjerbaTheme.textPrimary),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Generate a promo code for users or restaurants.",
                  style: TextStyle(color: DjerbaTheme.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 24),
                const Text("Promo Code", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const TextField(
                  decoration: InputDecoration(
                    hintText: "e.g., SUMMER2026",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.local_offer_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                const Text("Discount Percentage", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "e.g., 20",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.percent),
                  ),
                ),
                const SizedBox(height: 16),
                const Text("Description", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const TextField(
                  decoration: InputDecoration(
                    hintText: "e.g., 20% off all orders",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description_outlined),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text("Cancel"),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Discount created successfully!"),
                              backgroundColor: DjerbaTheme.success,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DjerbaTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text("Create", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
