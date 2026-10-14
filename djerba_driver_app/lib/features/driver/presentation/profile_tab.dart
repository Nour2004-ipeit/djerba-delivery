import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  Widget _buildStatCard(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.withOpacity(0.15)),
        ),
        child: Column(
          children: [
            Icon(icon, color: DjerbaTheme.primaryColor, size: 24),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            Text(label, style: const TextStyle(color: DjerbaTheme.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementCard(IconData icon, Color iconColor, String title, String subtitle, double progress, String percentage) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                    Text(percentage, style: TextStyle(color: DjerbaTheme.primaryColor, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: DjerbaTheme.textSecondary, fontSize: 12)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(DjerbaTheme.primaryColor),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountItem(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: DjerbaTheme.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: DjerbaTheme.primaryColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          const Icon(Icons.chevron_right, color: DjerbaTheme.textSecondary),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Profile Info
              Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.withOpacity(0.2), width: 2),
                      image: const DecorationImage(
                        image: NetworkImage('https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&q=80&w=200'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Alex Martinez", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                        const Text("alex.martinez@email.com", style: TextStyle(color: DjerbaTheme.textSecondary)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.military_tech_outlined, color: DjerbaTheme.primaryColor, size: 16),
                            const SizedBox(width: 4),
                            Text("Pro Delivery Partner", style: TextStyle(color: DjerbaTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Stats Row
              Row(
                children: [
                  _buildStatCard(Icons.inventory_2_outlined, "1,247", "Deliveries"),
                  const SizedBox(width: 12),
                  _buildStatCard(Icons.star_border, "4.9", "Rating"),
                  const SizedBox(width: 12),
                  _buildStatCard(Icons.access_time, "892h", "Hours"),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Earnings Comparison Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: DjerbaTheme.primaryLight,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: DjerbaTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.attach_money, color: Colors.white, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("This Week's\nEarnings", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, height: 1.2)),
                          const SizedBox(height: 4),
                          const Text("vs. \$423.25 last week", style: TextStyle(color: DjerbaTheme.textSecondary, fontSize: 12)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text("\$487.50", style: TextStyle(color: DjerbaTheme.primaryColor, fontWeight: FontWeight.w900, fontSize: 28)),
                        Row(
                          children: [
                            const Icon(Icons.trending_up, color: DjerbaTheme.primaryColor, size: 16),
                            const SizedBox(width: 4),
                            Text("+15.2%", style: TextStyle(color: DjerbaTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Achievements
              const Row(
                children: [
                  Icon(Icons.military_tech_outlined, color: DjerbaTheme.primaryColor),
                  SizedBox(width: 8),
                  Text("Achievements", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                ],
              ),
              const SizedBox(height: 16),
              _buildAchievementCard(
                Icons.bolt, 
                const Color(0xFFEF4444), 
                "Speed Demon", 
                "100 deliveries under 20 min", 
                0.78, 
                "78%"
              ),
              _buildAchievementCard(
                Icons.star, 
                const Color(0xFFF59E0B), 
                "5-Star Hero", 
                "50 consecutive 5-star ratings", 
                0.92, 
                "92%"
              ),
              _buildAchievementCard(
                Icons.pedal_bike, 
                const Color(0xFF8B5CF6), 
                "Distance Champion", 
                "500 km total distance", 
                0.65, 
                "65%"
              ),
              
              const SizedBox(height: 32),
              
              // Account Settings
              const Text("ACCOUNT", style: TextStyle(color: DjerbaTheme.textSecondary, fontWeight: FontWeight.bold, letterSpacing: 1)),
              const SizedBox(height: 16),
              _buildAccountItem(Icons.person_outline, "Personal Information"),
              _buildAccountItem(Icons.two_wheeler, "Vehicle Details"),
              _buildAccountItem(Icons.settings_outlined, "Settings"),
              _buildAccountItem(Icons.help_outline, "Help & Support"),
              
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text(
                    "Log Out",
                    style: TextStyle(color: DjerbaTheme.danger, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
