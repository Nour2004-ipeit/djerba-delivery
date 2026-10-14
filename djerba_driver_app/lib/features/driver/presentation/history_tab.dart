import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});

  Widget _buildSummaryCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          Text(label, style: const TextStyle(color: DjerbaTheme.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildCompletedDelivery({
    required String restaurantName,
    required String restaurantImage,
    required String customerName,
    required String address,
    required int rating,
    required String date,
    required String duration,
    required String distance,
    required String earnings,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.network(
                  restaurantImage,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(restaurantName, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                    Text("to $customerName", style: const TextStyle(color: DjerbaTheme.textSecondary, fontSize: 14)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: DjerbaTheme.successLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: DjerbaTheme.success.withOpacity(0.5)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_outline, color: DjerbaTheme.success, size: 14),
                    SizedBox(width: 4),
                    Text("Completed", style: TextStyle(color: DjerbaTheme.success, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 16, color: DjerbaTheme.textSecondary),
              const SizedBox(width: 8),
              Text(address, style: const TextStyle(color: DjerbaTheme.textSecondary)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: const Color(0xFFF59E0B),
                    size: 16,
                  );
                }),
              ),
              const SizedBox(width: 8),
              const Text("Customer rating", style: TextStyle(color: DjerbaTheme.textSecondary, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 14, color: DjerbaTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text(date, style: const TextStyle(color: DjerbaTheme.textSecondary, fontSize: 12)),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 14, color: DjerbaTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text(duration, style: const TextStyle(color: DjerbaTheme.textSecondary, fontSize: 12)),
                ],
              ),
              Text(distance, style: const TextStyle(color: DjerbaTheme.textSecondary, fontSize: 12)),
              Text(earnings, style: const TextStyle(color: DjerbaTheme.primaryColor, fontWeight: FontWeight.w900, fontSize: 18)),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Activity History", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
                  Text("Your delivery performance", style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                ],
              ),
            ),
            const Divider(height: 1),
            
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                physics: const BouncingScrollPhysics(),
                children: [
                  // Time Filters
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.withOpacity(0.3)),
                        ),
                        child: const Text("Today", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00A8C6), // Match screenshot cyan color
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text("This Week", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.withOpacity(0.3)),
                        ),
                        child: const Text("This Month", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Summary Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: DjerbaTheme.primaryLight,
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.trending_up, color: DjerbaTheme.primaryColor),
                            const SizedBox(width: 8),
                            const Text("This Week's Summary", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // The grid
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 2 - 46,
                              child: _buildSummaryCard(
                                icon: Icons.attach_money,
                                iconColor: DjerbaTheme.primaryColor,
                                value: "487.50 TND",
                                label: "Earnings",
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 2 - 46,
                              child: _buildSummaryCard(
                                icon: Icons.inventory_2_outlined,
                                iconColor: const Color(0xFF00A8C6),
                                value: "42",
                                label: "Deliveries",
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 2 - 46,
                              child: _buildSummaryCard(
                                icon: Icons.access_time,
                                iconColor: DjerbaTheme.primaryColor,
                                value: "28.5h",
                                label: "Hours",
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 2 - 46,
                              child: _buildSummaryCard(
                                icon: Icons.star_border,
                                iconColor: const Color(0xFFF59E0B),
                                value: "4.9",
                                label: "Avg Rating",
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 2 - 46,
                              child: _buildSummaryCard(
                                icon: Icons.location_on_outlined,
                                iconColor: DjerbaTheme.textPrimary,
                                value: "98.4 km",
                                label: "Distance",
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  const Text("Completed Deliveries", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 16),
                  
                  // Delivery List
                  _buildCompletedDelivery(
                    restaurantName: "La Bella Italia",
                    restaurantImage: "https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&q=80&w=100",
                    customerName: "Sarah J.",
                    address: "456 Oak Avenue, Apt 12",
                    rating: 5,
                    date: "Today, 2:30 PM",
                    duration: "28 min",
                    distance: "2.3 km",
                    earnings: "8.50 TND",
                  ),
                  _buildCompletedDelivery(
                    restaurantName: "Sakura Sushi",
                    restaurantImage: "https://images.unsplash.com/photo-1579871494447-9811cf80d66c?auto=format&fit=crop&q=80&w=100",
                    customerName: "Mike T.",
                    address: "321 Pine Road",
                    rating: 5,
                    date: "Today, 1:15 PM",
                    duration: "22 min",
                    distance: "3.1 km",
                    earnings: "11.00 TND",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
