import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class ClientHomeScreen extends StatelessWidget {
  const ClientHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top App Bar ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.arrow_back_rounded, size: 28, color: AppColors.textPrimary),
                  Text(
                    'Restaurants populaires',
                    style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
                  ),
                  const Icon(Icons.tune_rounded, size: 28, color: AppColors.textPrimary),
                ],
              ),
            ),

            // ── Filters (Pill Chips) ─────────────────────────────────
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _FilterChip(label: 'Recommandés', isSelected: true),
                  _FilterChip(label: 'Mieux notés'),
                  _FilterChip(label: 'Plus proches'),
                  _FilterChip(label: 'Plus rapides'),
                ],
              ),
            ),
            
            const SizedBox(height: 24),

            // ── Restaurant List ──────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: const [
                  _RestaurantCard(
                    name: 'Chez Bilel',
                    categories: 'Fruits de mer • Tunisienne • Méditerranéenne',
                    imageUrl: 'https://picsum.photos/800/400?random=1',
                    rating: 4.8,
                    time: '20-30 min',
                    distance: '1.2 km',
                    badge: 'Livraison gratuite',
                    badgeColor: AppColors.djerbaBlueLight,
                    badgeTextColor: AppColors.djerbaBlue,
                    badgeIcon: Icons.moped_rounded,
                  ),
                  SizedBox(height: 24),
                  _RestaurantCard(
                    name: 'Dar El Bhar',
                    categories: 'Tunisienne • Traditionnelle • Poissons',
                    imageUrl: 'https://picsum.photos/800/400?random=2',
                    rating: 4.8,
                    time: '20-30 min',
                    distance: '1.2 km',
                    badge: 'Halal',
                    badgeColor: Color(0xFFDCFCE7), // Light green
                    badgeTextColor: AppColors.djerbaGreen,
                    badgeIcon: Icons.park_rounded,
                  ),
                  SizedBox(height: 24),
                  _RestaurantCard(
                    name: 'Café Djerba',
                    categories: 'Méditerranéenne • Café • Sandwichs',
                    imageUrl: 'https://picsum.photos/800/400?random=3',
                    rating: 4.6,
                    time: '15-20 min',
                    distance: '0.8 km',
                    badge: 'Livraison gratuite',
                    badgeColor: AppColors.djerbaBlueLight,
                    badgeTextColor: AppColors.djerbaBlue,
                    badgeIcon: Icons.moped_rounded,
                  ),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _FilterChip({required this.label, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.djerbaBlue : AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: isSelected ? null : Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: AppTypography.labelMedium.copyWith(
          color: isSelected ? Colors.white : AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _RestaurantCard extends StatelessWidget {
  final String name;
  final String categories;
  final String imageUrl;
  final double rating;
  final String time;
  final String distance;
  final String badge;
  final Color badgeColor;
  final Color badgeTextColor;
  final IconData badgeIcon;

  const _RestaurantCard({
    required this.name,
    required this.categories,
    required this.imageUrl,
    required this.rating,
    required this.time,
    required this.distance,
    required this.badge,
    required this.badgeColor,
    required this.badgeTextColor,
    required this.badgeIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.textTertiary.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Header with Heart
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: Image.network(
                  imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite_border_rounded,
                    color: AppColors.textPrimary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          
          // Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  categories,
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                
                // Bottom Info Row
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: AppColors.djerbaGold, size: 18),
                    const SizedBox(width: 4),
                    Text(rating.toString(), style: AppTypography.labelMedium),
                    const SizedBox(width: 12),
                    
                    const Icon(Icons.access_time_rounded, color: AppColors.textSecondary, size: 16),
                    const SizedBox(width: 4),
                    Text(time, style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(width: 12),
                    
                    const Icon(Icons.location_on_outlined, color: AppColors.textSecondary, size: 16),
                    const SizedBox(width: 4),
                    Text(distance, style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
                    
                    const Spacer(),
                    
                    // Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(badgeIcon, color: badgeTextColor, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            badge,
                            style: AppTypography.caption.copyWith(
                              color: badgeTextColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
