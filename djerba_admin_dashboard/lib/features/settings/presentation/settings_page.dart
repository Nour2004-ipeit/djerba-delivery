import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Platform Settings", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
          const SizedBox(height: 32),
          Expanded(
            child: ListView(
              children: [
                // Localization Settings
                _buildSettingsSection(
                  "Localization",
                  "Configure platform languages and regional settings.",
                  Icons.language,
                  [
                    _buildDropdownRow("Default Platform Language", ["English (EN)", "Français (FR)", "العربية (AR)"], "English (EN)"),
                    _buildToggleRow("Allow users to change language", true),
                  ],
                ),
                const SizedBox(height: 24),
                // Notification Settings
                _buildSettingsSection(
                  "Notifications",
                  "Manage email and push notifications for admins.",
                  Icons.notifications,
                  [
                    _buildToggleRow("New Restaurant Alerts", true),
                    _buildToggleRow("Driver Payout Reminders", true),
                    _buildToggleRow("System Error Alerts", false),
                  ],
                ),
                const SizedBox(height: 24),
                // Security Settings
                _buildSettingsSection(
                  "Security",
                  "Manage authentication and access controls.",
                  Icons.security,
                  [
                    _buildToggleRow("Require 2FA for Super Admins", true),
                    _buildButtonRow("Change Admin Password", "Update"),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(String title, String subtitle, IconData icon, List<Widget> children) {
    return Container(
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
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: DjerbaTheme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: DjerbaTheme.primaryColor),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(subtitle, style: const TextStyle(color: DjerbaTheme.textSecondary, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(height: 1),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildToggleRow(String title, bool value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          Switch(
            value: value,
            onChanged: (bool newValue) {},
            activeColor: DjerbaTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownRow(String title, List<String> options, String currentValue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          DropdownButton<String>(
            value: currentValue,
            items: options.map((String val) {
              return DropdownMenuItem<String>(
                value: val,
                child: Text(val),
              );
            }).toList(),
            onChanged: (_) {},
          ),
        ],
      ),
    );
  }

  Widget _buildButtonRow(String title, String buttonText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: DjerbaTheme.primaryColor,
              side: const BorderSide(color: DjerbaTheme.primaryColor),
            ),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }
}
