import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:line_icons/line_icons.dart';
import '../../../core/theme.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import 'favorites_service.dart';
import 'order_service.dart';
import 'user_service.dart';
import '../../cart/presentation/cart_service.dart';
import '../../../core/localization_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/restaurant_provider.dart';

class ClientDashboard extends ConsumerStatefulWidget {
  const ClientDashboard({super.key});

  @override
  ConsumerState<ClientDashboard> createState() => _ClientDashboardState();
}

class _ClientDashboardState extends ConsumerState<ClientDashboard> {
  int _navIndex = 0;
  int _selectedCategoryIndex = -1;
  String _selectedSort = 'Recommended';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categoryNames = [
    "Traditionnel",
    "Pizza",
    "Fast Food",
    "Fruits de mer",
    "Healthy",
    "Desserts"
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Sort by", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSortOption('Recommended', Icons.person_outline, setModalState),
                  _buildSortOption('Near me', Icons.location_on_outlined, setModalState),
                  _buildSortOption('Ratings', Icons.thumb_up_outlined, setModalState),
                  _buildSortOption('Delivery fee', Icons.directions_bike_outlined, setModalState),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DjerbaTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text("Show results", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }

  Widget _buildSortOption(String title, IconData icon, StateSetter setModalState) {
    return InkWell(
      onTap: () {
        setModalState(() => _selectedSort = title);
        setState(() {}); // Update main UI as well
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: Colors.black87, size: 22),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
            Icon(
              _selectedSort == title ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: _selectedSort == title ? DjerbaTheme.primaryColor : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategory(int index, String title, String imageUrl) {
    bool isSelected = _selectedCategoryIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategoryIndex = index;
          _searchQuery = _categoryNames[index];
          _searchController.text = _searchQuery;
          _navIndex = 1; // Jump to search tab
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? DjerbaTheme.primaryColor : Colors.transparent,
                  width: isSelected ? 3.0 : 0.0,
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4)),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(3.0),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: isSelected ? Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: DjerbaTheme.primaryColor.withOpacity(0.4),
                    ),
                  ) : null,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? DjerbaTheme.primaryColor : DjerbaTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantCard(String id, String name, String rating, String time, String distance, String imageUrl) {
    return RestaurantCard(id: id, name: name, rating: rating, time: time, distance: distance, imageUrl: imageUrl);
  }

  Widget _buildExplorerTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (Location & Profile)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on, color: DjerbaTheme.primaryColor, size: 20),
                    const SizedBox(width: 8),
                    const Text("Houmt Souk, Djerba", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down, size: 20, color: DjerbaTheme.textSecondary),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: const Icon(Icons.notifications_outlined, color: DjerbaTheme.textPrimary, size: 22),
                ),
              ],
            ),
          ),

          // Greeting
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: ListenableBuilder(
              listenable: UserService(),
              builder: (context, _) {
                final firstName = UserService().name.split(' ').first;
                return Text(
                  "Bonjour $firstName 👋",
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1.0),
                );
              }
            ),
          ),
          const SizedBox(height: 16),

          // Search Bar (Redirects to Search Tab)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: GestureDetector(
              onTap: () {
                setState(() { _navIndex = 1; });
              },
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    const Icon(Icons.search, color: DjerbaTheme.textSecondary),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "Rechercher restaurant ou plat",
                        style: TextStyle(color: DjerbaTheme.textTertiary, fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Categories
          SizedBox(
            height: 110,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildCategory(0, "Traditionnel", "https://images.unsplash.com/photo-1541518763669-27fef04b14ea?auto=format&fit=crop&q=80&w=200"),
                _buildCategory(1, "Pizza", "https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&q=80&w=200"),
                _buildCategory(2, "Fast Food", "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&q=80&w=200"),
                _buildCategory(3, "Fruits de mer", "https://images.unsplash.com/photo-1615141982883-c7ad0e69fd62?auto=format&fit=crop&q=80&w=200"),
                _buildCategory(4, "Healthy", "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&q=80&w=200"),
                _buildCategory(5, "Desserts", "https://images.unsplash.com/photo-1551024601-bec78aea704b?auto=format&fit=crop&q=80&w=200"),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Promo Banner Placeholder
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: DjerbaTheme.primaryColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Center(
                child: Text(
                  "Livraison gratuite ce weekend",
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Popular Restaurants
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(LocalizationService().translate('popular_restaurants'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                Row(
                  children: [
                    Text(LocalizationService().translate('see_all'), style: const TextStyle(color: DjerbaTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_ios, size: 12, color: DjerbaTheme.primaryColor),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Horizontal List (LIVE API)
          SizedBox(
            height: 230,
            child: ref.watch(restaurantsProvider).when(
              data: (restaurants) {
                if (restaurants.isEmpty) {
                  return const Center(child: Text("Aucun restaurant trouvé."));
                }
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  physics: const BouncingScrollPhysics(),
                  itemCount: restaurants.length,
                  itemBuilder: (context, index) {
                    final restaurant = restaurants[index];
                    return _buildRestaurantCard(
                      restaurant.id,
                      restaurant.name,
                      restaurant.rating.toString(),
                      "25-35 min", // Mock time for now
                      "1.2 km",    // Mock distance for now
                      restaurant.imageUrl,
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Erreur: $error')),
            ),
          ),
          const SizedBox(height: 32),

          // Special Offers
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Offres Spéciales", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                Row(
                  children: [
                    Text(LocalizationService().translate('see_all'), style: const TextStyle(color: DjerbaTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_ios, size: 12, color: DjerbaTheme.primaryColor),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 230,
            child: ref.watch(restaurantsProvider).when(
              data: (restaurants) {
                if (restaurants.isEmpty) return const SizedBox();
                // Show reverse list for offers
                final offers = restaurants.reversed.take(3).toList();
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  physics: const BouncingScrollPhysics(),
                  itemCount: offers.length,
                  itemBuilder: (context, index) {
                    final restaurant = offers[index];
                    return _buildRestaurantCard(
                      restaurant.id,
                      restaurant.name,
                      restaurant.rating.toString(),
                      "20-30 min",
                      "1.5 km",
                      restaurant.imageUrl,
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => const SizedBox(),
            ),
          ),
          const SizedBox(height: 32),

          // New Arrivals
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Nouveautés", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                Row(
                  children: [
                    Text(LocalizationService().translate('see_all'), style: const TextStyle(color: DjerbaTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_ios, size: 12, color: DjerbaTheme.primaryColor),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 230,
            child: ref.watch(restaurantsProvider).when(
              data: (restaurants) {
                if (restaurants.isEmpty) return const SizedBox();
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  physics: const BouncingScrollPhysics(),
                  itemCount: restaurants.length > 2 ? 2 : restaurants.length,
                  itemBuilder: (context, index) {
                    final restaurant = restaurants[index];
                    return _buildRestaurantCard(
                      restaurant.id,
                      restaurant.name,
                      "Nouveau",
                      "35-45 min",
                      "3.5 km",
                      restaurant.imageUrl,
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => const SizedBox(),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSearchView() {
    return Column(
      children: [
        // App Bar & Search Input
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _navIndex = 0;
                    _searchQuery = '';
                    _searchController.clear();
                    _selectedCategoryIndex = -1;
                  });
                },
                child: const Icon(Icons.arrow_back, color: Colors.black),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: DjerbaTheme.primaryColor, width: 2),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.black87),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) {
                            setState(() { _searchQuery = val; });
                          },
                          decoration: const InputDecoration(
                            hintText: "Rechercher...",
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(color: Colors.black87, fontSize: 16),
                        ),
                      ),
                      if (_searchQuery.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _searchQuery = '';
                              _searchController.clear();
                              _selectedCategoryIndex = -1;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), shape: BoxShape.circle),
                            child: const Icon(Icons.close, size: 16, color: Colors.black54),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        
        Expanded(
          child: _searchQuery.isEmpty 
            ? _buildEmptySearchState()
            : ref.watch(productSearchProvider(_searchQuery)).when(
                data: (products) {
                  if (products.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.search_off, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text("Aucun plat trouvé", style: TextStyle(color: Colors.grey, fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      // product.description contains "description | Chez RestaurantName"
                      final descParts = product.description.split(' | Chez ');
                      final desc = descParts.isNotEmpty ? descParts[0] : '';
                      final restaurantName = descParts.length > 1 ? descParts[1] : 'Restaurant inconnu';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildSearchTrendItem(
                          product.name,
                          "Chez $restaurantName",
                          "4.5", // Static rating for now
                          "30 min",
                          product.price.toStringAsFixed(2),
                          product.imageUrl,
                          product.restaurantId,
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text("Erreur: $error")),
              ),
        ),
      ],
    );
  }

  Widget _buildEmptySearchState() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Glovo-style Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                _buildGlovoChip("Promotions", isSelected: false),
                _buildGlovoChip("Sandwich", isSelected: false),
                _buildGlovoChip("Pizza", isSelected: false),
                _buildGlovoChip("Food type", isDropdown: true),
                GestureDetector(
                  onTap: _showSortBottomSheet,
                  child: _buildGlovoChip("Sort by", isDropdown: true),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Tendances
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text("Tendances à Djerba 🔥", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          
          _buildSearchTrendItem("Couscous au poisson", "Chez Fatma", "4.7", "30 min", "22.00", "https://images.unsplash.com/photo-1541518763669-27fef04b14ea?auto=format&fit=crop&q=80&w=200", "rest_fatma"),
          _buildSearchTrendItem("Brik à l'œuf", "Café de la Plage", "4.6", "15 min", "4.50", "https://images.unsplash.com/photo-1628840042765-356cda07504e?auto=format&fit=crop&q=80&w=200", "rest_plage"),
          _buildSearchTrendItem("Pizza Margherita", "Positano Djerba", "4.5", "25 min", "18.00", "https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&q=80&w=200", "rest_positano"),
          
          const SizedBox(height: 24),
          
          // Filtres rapides
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text("Filtres rapides", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                _buildFilterChip("Note 4.5+", Icons.star, DjerbaTheme.primaryColor),
                _buildFilterChip("Livraison <30min", Icons.access_time, DjerbaTheme.primaryColor),
                _buildFilterChip("Halal", Icons.mosque, DjerbaTheme.primaryColor),
                _buildFilterChip("Végétarien", Icons.eco_outlined, DjerbaTheme.primaryColor),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildGlovoChip(String text, {bool isSelected = false, bool isDropdown = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? DjerbaTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? DjerbaTheme.primaryColor : Colors.grey.shade300,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
              color: isSelected ? DjerbaTheme.primaryColor : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 14,
            ),
          ),
          if (isDropdown) ...[
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.black54),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchTrendItem(String title, String restaurant, String rating, String time, String priceStr, String imageUrl, String id) {
    return GestureDetector(
      onTap: () {
        context.push('/restaurant_detail', extra: {'id': id, 'name': title, 'imageUrl': imageUrl});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(restaurant, style: const TextStyle(color: DjerbaTheme.textSecondary, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star, color: DjerbaTheme.primaryColor, size: 16),
                          const SizedBox(width: 4),
                          Text(rating, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(time, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.construction, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          const Text("Fonctionnalité à venir", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildOrdersView() {
    return ListenableBuilder(
      listenable: OrderService(),
      builder: (context, _) {
        final service = OrderService();
        if (service.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        final orders = service.pastOrders;
        if (orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                const Text("Aucune commande pour le moment", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 8)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(order.id, style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: DjerbaTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(order.status, style: const TextStyle(color: DjerbaTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(image: NetworkImage(order.restaurantImage), fit: BoxFit.cover),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(order.restaurantName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            const SizedBox(height: 4),
                            Text("${order.date.day}/${order.date.month}/${order.date.year}", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                          ],
                        ),
                      ),
                      Text("${order.total.toStringAsFixed(1)} TND", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: order.items.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Text("${item.quantity}x", style: const TextStyle(fontWeight: FontWeight.bold, color: DjerbaTheme.primaryColor)),
                            const SizedBox(width: 12),
                            Expanded(child: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w500))),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      if (order.status != 'delivered' && order.status != 'cancelled')
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ElevatedButton(
                              onPressed: () {
                                context.push('/tracking', extra: order.id);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF5A623), // Orange/Yellow accent
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: const Text("Suivre", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Reorder logic
                            CartService().clear();
                            for (var item in order.items) {
                              for (int i = 0; i < item.quantity; i++) {
                                CartService().addItem(item.productId, order.restaurantId, item.title, item.price, item.imageUrl, description: item.description);
                              }
                            }
                            context.go('/cart'); // Jump to cart
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: DjerbaTheme.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text("Recommander", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProfileView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Center(
            child: ListenableBuilder(
              listenable: UserService(),
              builder: (context, _) {
                final user = UserService();
                return Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: DjerbaTheme.primaryColor,
                      child: Icon(Icons.person, size: 50, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Text(user.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(user.phone, style: const TextStyle(color: DjerbaTheme.textSecondary, fontSize: 14)),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 40),
          _buildProfileOption(Icons.person_outline, LocalizationService().translate('personal_info'), onTap: () => context.push('/edit_profile')),
          _buildProfileOption(Icons.favorite_border, LocalizationService().translate('my_favorites'), onTap: () => context.push('/favorites')),
          _buildProfileOption(Icons.location_on_outlined, LocalizationService().translate('my_addresses'), onTap: () => context.push('/addresses')),
          _buildProfileOption(Icons.credit_card_outlined, LocalizationService().translate('payment_methods'), onTap: () => context.push('/payment_methods')),
          _buildProfileOption(Icons.local_offer_outlined, "Bons de réduction et Promos", onTap: () => context.push('/vouchers')),
          _buildProfileOption(Icons.receipt_long_outlined, LocalizationService().translate('order_history')),
          _buildProfileOption(Icons.language_outlined, LocalizationService().translate('languages'), trailingText: LocalizationService().currentLanguageCode.toUpperCase(), onTap: () => context.push('/languages')),
          const Divider(height: 32),
          _buildProfileOption(Icons.card_giftcard, "Parrainer un ami", onTap: () => context.push('/referral')),
          _buildProfileOption(Icons.settings_outlined, LocalizationService().translate('settings')),
          _buildProfileOption(Icons.help_outline, LocalizationService().translate('help_support'), onTap: () => context.push('/help')),
          _buildProfileOption(Icons.logout, LocalizationService().translate('logout'), isDestructive: true, onTap: () => context.go('/login')),
        ],
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title, {String? trailingText, bool isDestructive = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: isDestructive ? Colors.red : DjerbaTheme.primaryColor),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: isDestructive ? Colors.red : DjerbaTheme.textPrimary))),
          if (trailingText != null) ...[
            Text(trailingText, style: const TextStyle(color: DjerbaTheme.textSecondary, fontSize: 13)),
            const SizedBox(width: 8),
          ],
            if (!isDestructive) const Icon(Icons.arrow_forward_ios, color: DjerbaTheme.textTertiary, size: 14),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    switch (_navIndex) {
      case 1:
        body = _buildSearchView();
        break;
      case 2:
        body = _buildOrdersView();
        break;
      case 3:
        body = _buildProfileView();
        break;
      case 0:
      default:
        body = _buildExplorerTab();
    }

    return ListenableBuilder(
      listenable: LocalizationService(),
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFFAFAFA),
          body: SafeArea(child: body),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            )
          ]
        ),
        child: BottomNavigationBar(
          currentIndex: _navIndex,
          onTap: (index) {
            setState(() {
              _navIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: DjerbaTheme.primaryColor,
          unselectedItemColor: DjerbaTheme.textTertiary,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          items: [
            BottomNavigationBarItem(icon: const Icon(Icons.home_filled), label: LocalizationService().translate('home_tab')),
            BottomNavigationBarItem(icon: const Icon(Icons.search), label: LocalizationService().translate('search_tab')),
            BottomNavigationBarItem(icon: const Icon(Icons.shopping_bag_outlined), label: LocalizationService().translate('orders_tab')),
            BottomNavigationBarItem(icon: const Icon(Icons.person_outline), label: LocalizationService().translate('profile_tab')),
          ],
        ),
      ),
    );
      },
    );
  }
}

class RestaurantCard extends StatefulWidget {
  final String id;
  final String name;
  final String rating;
  final String time;
  final String distance;
  final String imageUrl;

  const RestaurantCard({
    super.key,
    required this.id,
    required this.name,
    required this.rating,
    required this.time,
    required this.distance,
    required this.imageUrl,
  });

  @override
  State<RestaurantCard> createState() => _RestaurantCardState();
}

class _RestaurantCardState extends State<RestaurantCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/restaurant_detail', extra: {'id': widget.id, 'name': widget.name, 'imageUrl': widget.imageUrl});
      },
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Container(
              height: 140,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(widget.imageUrl),
                  fit: BoxFit.cover,
                ),
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 12,
                    right: 12,
                    child: ListenableBuilder(
                      listenable: FavoritesService(),
                      builder: (context, _) {
                        final isFav = FavoritesService().isRestaurantFavorite(widget.name);
                        return GestureDetector(
                          onTap: () {
                            FavoritesService().toggleRestaurant(widget.name);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              size: 18,
                              color: isFav ? Colors.red : DjerbaTheme.textPrimary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.name,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: DjerbaTheme.primaryColor, size: 16),
                          const SizedBox(width: 4),
                          Text(widget.rating, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 14, color: DjerbaTheme.textSecondary),
                      const SizedBox(width: 4),
                      Text(widget.time, style: const TextStyle(fontSize: 12, color: DjerbaTheme.textSecondary)),
                      const SizedBox(width: 12),
                      const Icon(Icons.location_on_outlined, size: 14, color: DjerbaTheme.textSecondary),
                      const SizedBox(width: 4),
                      Text(widget.distance, style: const TextStyle(fontSize: 12, color: DjerbaTheme.textSecondary)),
                    ],
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

