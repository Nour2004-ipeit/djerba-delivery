import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../../menu/presentation/providers.dart';

class RestaurantShell extends StatelessWidget {
  final Widget child;

  const RestaurantShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();

    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 250,
            color: Colors.white,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    "Djerba Restaurant",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: DjerbaTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildNavItem(context, "Overview", Icons.dashboard_outlined, "/dashboard", location),
                _buildNavItem(context, "Live Orders", Icons.list_alt, "/orders", location),
                _buildNavItem(context, "Menu Manager", Icons.restaurant_menu, "/menu", location),
                const Spacer(),
                const Divider(),
                _buildNavItem(context, "Settings", Icons.settings_outlined, "/settings", location),
                _buildNavItem(context, "Logout", Icons.logout, "/", location),
                const SizedBox(height: 24),
              ],
            ),
          ),
          const VerticalDivider(width: 1, thickness: 1),
          
          // Main Content Area
          Expanded(
            child: Column(
              children: [
                // Top App Bar
                Container(
                  height: 70,
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: DjerbaTheme.successLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.circle, color: DjerbaTheme.success, size: 12),
                            SizedBox(width: 8),
                            Text("Accepting Orders", style: TextStyle(color: DjerbaTheme.success, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      const Icon(Icons.notifications_none, color: DjerbaTheme.textSecondary),
                      const SizedBox(width: 24),
                      Row(
                        children: [
                          Consumer(
                            builder: (context, ref, child) {
                              final imageAsync = ref.watch(myRestaurantImageProvider);
                              final imageUrl = imageAsync.value;
                              return CircleAvatar(
                                radius: 16,
                                backgroundImage: imageUrl != null && imageUrl.isNotEmpty
                                    ? NetworkImage(imageUrl)
                                    : const NetworkImage("https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&q=80&w=100"),
                              );
                            },
                          ),
                          const SizedBox(width: 12),
                          Consumer(
                            builder: (context, ref, child) {
                              final nameAsync = ref.watch(myRestaurantNameProvider);
                              final name = nameAsync.when(
                                data: (data) => data != null && data.isNotEmpty ? data : "Al Atika",
                                loading: () => "Al Atika",
                                error: (_, __) => "Al Atika",
                              );
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  const Text("Admin", style: TextStyle(color: DjerbaTheme.textSecondary, fontSize: 12)),
                                ],
                              );
                            },
                          ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 1, thickness: 1),
                
                // Page Content
                Expanded(
                  child: Container(
                    color: DjerbaTheme.backgroundLight,
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, String title, IconData icon, String path, String currentLocation) {
    final bool isSelected = currentLocation.startsWith(path) && path != '/';
    return InkWell(
      onTap: () {
        if (path == '/') {
           context.go('/'); // logout to login page
        } else {
           context.go(path);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          border: isSelected ? const Border(right: BorderSide(color: DjerbaTheme.primaryColor, width: 4)) : null,
          color: isSelected ? DjerbaTheme.primaryLight : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? DjerbaTheme.primaryColor : DjerbaTheme.textSecondary, size: 20),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? DjerbaTheme.primaryColor : DjerbaTheme.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
