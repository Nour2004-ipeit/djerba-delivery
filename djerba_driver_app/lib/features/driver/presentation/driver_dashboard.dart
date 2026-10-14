import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';

class DriverDashboard extends StatefulWidget {
  const DriverDashboard({super.key});

  @override
  State<DriverDashboard> createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> {
  bool _isOnline = true;
  int _navIndex = 0;

  Widget _buildDeliveryRequest() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: DjerbaTheme.primaryColor.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: DjerbaTheme.primaryColor.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: DjerbaTheme.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "NOUVELLE COURSE",
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                ),
              ),
              const Text(
                "8.50 DT",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: DjerbaTheme.primaryColor),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          Row(
            children: [
              Column(
                children: [
                  const Icon(Icons.storefront, color: DjerbaTheme.textSecondary, size: 20),
                  Container(width: 2, height: 24, color: Colors.grey.withOpacity(0.3)),
                  const Icon(Icons.location_on, color: DjerbaTheme.primaryColor, size: 20),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Dar Djerba", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const Text("Houmt Souk", style: TextStyle(color: DjerbaTheme.textSecondary, fontSize: 12)),
                    const SizedBox(height: 12),
                    const Text("Maison 42, Rue de la Plage", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const Text("Midoun (4.2 km)", style: TextStyle(color: DjerbaTheme.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    side: BorderSide(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: const Text("Refuser", style: TextStyle(color: DjerbaTheme.textSecondary, fontWeight: FontWeight.bold)),
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
                  child: const Text("Accepter", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F8),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/roles'),
        ),
        title: Column(
          children: [
            const Text("Mode Livreur", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _isOnline ? DjerbaTheme.success : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _isOnline ? "En ligne" : "Hors ligne",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _isOnline ? DjerbaTheme.success : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          Switch(
            value: _isOnline,
            onChanged: (val) {
              setState(() {
                _isOnline = val;
              });
            },
            activeColor: DjerbaTheme.primaryColor,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Fake Map Background
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage('https://maps.googleapis.com/maps/api/staticmap?center=Houmt+Souk,Djerba&zoom=13&size=600x800&key=YOUR_API_KEY'), // Placeholder, will fail gracefully
                  fit: BoxFit.cover,
                ),
                color: Color(0xFFE5E3DF), // Map fallback color
              ),
              child: Stack(
                children: [
                  // Fake map lines for visual representation
                  Positioned(top: 100, left: 50, child: Container(width: 200, height: 8, color: Colors.white)),
                  Positioned(top: 100, left: 150, child: Container(width: 8, height: 300, color: Colors.white)),
                  Positioned(top: 250, left: 150, child: Container(width: 150, height: 8, color: Colors.white)),
                  
                  // Location marker
                  Positioned(
                    top: 230,
                    left: 130,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: DjerbaTheme.primaryColor.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: DjerbaTheme.primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Stats Overlay (Top)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                      ),
                      child: const Column(
                        children: [
                          Text("Gains aujourd'hui", style: TextStyle(fontSize: 11, color: DjerbaTheme.textSecondary, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text("42.50 DT", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: DjerbaTheme.primaryColor)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                      ),
                      child: const Column(
                        children: [
                          Text("Courses", style: TextStyle(fontSize: 11, color: DjerbaTheme.textSecondary, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text("6", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: DjerbaTheme.textPrimary)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // New Request Bottom Sheet
            if (_isOnline)
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: _buildDeliveryRequest(),
              ),
          ],
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
          BottomNavBarItem(icon: Icons.map, label: "Carte"),
          BottomNavBarItem(icon: Icons.list_alt, label: "Historique"),
          BottomNavBarItem(icon: Icons.account_balance_wallet, label: "Gains"),
          BottomNavBarItem(icon: Icons.person, label: "Profil"),
        ],
      ),
    );
  }
}
