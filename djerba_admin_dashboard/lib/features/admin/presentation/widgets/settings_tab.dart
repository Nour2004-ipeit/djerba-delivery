import 'package:flutter/material.dart';
import '../../../../core/theme.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Settings & Preferences", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(height: 24),
            
            _buildSectionTitle("Profile"),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: DjerbaTheme.primaryColor,
                    child: Icon(Icons.admin_panel_settings, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Super Admin", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        Text("admin@djerba.com", style: TextStyle(color: DjerbaTheme.textSecondary)),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Edit"),
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            _buildSectionTitle("App Settings"),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text("Dark Mode", style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text("Toggle dark theme interface"),
                    secondary: const Icon(Icons.dark_mode_outlined, color: DjerbaTheme.primaryColor),
                    value: _isDarkMode,
                    activeColor: DjerbaTheme.primaryColor,
                    onChanged: (val) {
                      setState(() => _isDarkMode = val);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Dark mode integration pending state management update.")));
                    },
                  ),
                  Divider(color: Colors.grey.withOpacity(0.1), height: 1),
                  SwitchListTile(
                    title: const Text("Push Notifications", style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text("Get alerts for new restaurant requests"),
                    secondary: const Icon(Icons.notifications_active_outlined, color: DjerbaTheme.primaryColor),
                    value: _notificationsEnabled,
                    activeColor: DjerbaTheme.primaryColor,
                    onChanged: (val) => setState(() => _notificationsEnabled = val),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            Center(
              child: TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.logout, color: DjerbaTheme.danger),
                label: const Text("Log Out", style: TextStyle(color: DjerbaTheme.danger, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: DjerbaTheme.textSecondary),
    );
  }
}
