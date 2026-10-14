import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../../../core/providers/language_provider.dart';

class AdminShell extends ConsumerWidget {
  final Widget child;

  const AdminShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String location = GoRouterState.of(context).uri.toString();
    final String lang = ref.watch(languageProvider);

    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 260,
            color: DjerbaTheme.darkBlue,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Icon(Icons.admin_panel_settings, color: Colors.white, size: 32),
                      SizedBox(width: 12),
                      Text(
                        "Djerba Admin",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildNavItem(context, translate('platform_overview', lang), Icons.dashboard, "/overview", location),
                _buildNavItem(context, translate('user_management', lang), Icons.people, "/users", location),
                _buildNavItem(context, translate('delivery_tracking', lang), Icons.map, "/tracking", location),
                _buildNavItem(context, translate('marketing_promos', lang), Icons.local_offer, "/marketing", location),
                _buildNavItem(context, translate('support_tickets', lang), Icons.support_agent, "/support", location),
                const Spacer(),
                const Divider(color: Colors.white24),
                _buildNavItem(context, translate('settings', lang), Icons.settings, "/settings", location),
                _buildNavItem(context, translate('logout', lang), Icons.logout, "/", location),
                const SizedBox(height: 24),
              ],
            ),
          ),
          
          // Main Content Area
          Expanded(
            child: Column(
              children: [
                // Top App Bar
                Container(
                  height: 70,
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Global Search
                      Container(
                        width: 400,
                        height: 40,
                        decoration: BoxDecoration(
                          color: DjerbaTheme.backgroundLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            const Icon(Icons.search, color: DjerbaTheme.textSecondary, size: 20),
                            const SizedBox(width: 8),
                            Text(translate('search', lang), style: const TextStyle(color: DjerbaTheme.textSecondary, fontSize: 14)),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          DropdownButton<String>(
                            value: lang,
                            icon: const Icon(Icons.language, color: DjerbaTheme.textSecondary),
                            underline: const SizedBox(),
                            items: const [
                              DropdownMenuItem(value: 'en', child: Text('English')),
                              DropdownMenuItem(value: 'fr', child: Text('Français')),
                              DropdownMenuItem(value: 'ar', child: Text('العربية')),
                            ],
                            onChanged: (String? newLang) {
                              if (newLang != null) {
                                ref.read(languageProvider.notifier).setLanguage(newLang);
                              }
                            },
                          ),
                          const SizedBox(width: 24),
                          const Icon(Icons.notifications_active, color: DjerbaTheme.primaryColor),
                          const SizedBox(width: 24),
                          Row(
                            children: [
                              const CircleAvatar(
                                radius: 16,
                                backgroundImage: NetworkImage("https://images.unsplash.com/photo-1560250097-0b93528c311a?auto=format&fit=crop&q=80&w=100"),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(translate('admin_user', lang), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  Text(translate('super_admin', lang), style: const TextStyle(color: DjerbaTheme.textSecondary, fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
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
           context.go('/');
        } else {
           context.go(path);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          border: isSelected ? const Border(left: BorderSide(color: DjerbaTheme.primaryColor, width: 4)) : null,
          color: isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? DjerbaTheme.primaryColor : Colors.white70, size: 20),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
