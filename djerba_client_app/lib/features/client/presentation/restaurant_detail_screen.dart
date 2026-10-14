import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/restaurant_provider.dart';
import '../../cart/presentation/cart_screen.dart';
import '../../cart/presentation/cart_service.dart';
import 'favorites_service.dart';
import '../data/models.dart';

class RestaurantDetailScreen extends ConsumerStatefulWidget {
  final String id;
  final String name;
  final String imageUrl;

  const RestaurantDetailScreen({
    super.key,
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  @override
  ConsumerState<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends ConsumerState<RestaurantDetailScreen> {
  int _selectedTab = 0;
  bool _isFavorite = false;

  Widget _buildMetadataItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: DjerbaTheme.textSecondary),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12, color: DjerbaTheme.textSecondary, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 12,
      width: 1,
      color: Colors.grey.withOpacity(0.3),
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildMenuSectionChip(int index, String title) {
    bool isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? DjerbaTheme.primaryColor : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            fontSize: 14,
            color: isSelected ? Colors.white : DjerbaTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildSignatureDish(String id, String restaurantId, String name, String price, String imageUrl) {
    return SignatureDishCard(
      id: id,
      restaurantId: restaurantId,
      name: name,
      price: price,
      imageUrl: imageUrl,
    );
  }

  Widget _buildMenuItem(String id, String restaurantId, String title, String description, String price, String imageUrl, bool isAvailable) {
    return MenuItemCard(
      id: id,
      restaurantId: restaurantId,
      title: title,
      description: description,
      price: price,
      imageUrl: imageUrl,
      isAvailable: isAvailable,
    );
  }

  Widget _buildReviewItem(String name, int rating, String comment, String date) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < rating ? Icons.star : Icons.star_border,
                color: Colors.orange,
                size: 16,
              );
            }),
          ),
          const SizedBox(height: 12),
          Text(comment, style: const TextStyle(color: Colors.black87, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildMenuSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
        ),
        ...items,
        const Divider(height: 32),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.35,
            child: Image.network(
              widget.imageUrl,
              fit: BoxFit.cover,
            ),
          ),
          
          // Scrollable Content
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.name, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                        const SizedBox(height: 8),
                        const Text("Méditerranéen • Fruits de mer • Tunisien", style: TextStyle(color: DjerbaTheme.textSecondary, fontSize: 14)),
                        const SizedBox(height: 16),
                        
                        // Metadata Row
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildMetadataItem(Icons.star, "4.9 (320 avis)"),
                              _buildDivider(),
                              _buildMetadataItem(Icons.access_time, "25-35 min"),
                              _buildDivider(),
                              _buildMetadataItem(Icons.pedal_bike, "3 TND livraison"),
                              _buildDivider(),
                              _buildMetadataItem(Icons.location_on_outlined, "1.4 km"),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Live Products List via Riverpod
                        ref.watch(restaurantProductsProvider(widget.id)).when(
                          data: (products) {
                            if (products.isEmpty) {
                              return const Center(child: Text("Aucun produit disponible."));
                            }

                            // Group products by category
                            final Map<String, List<ProductModel>> groupedProducts = {};
                            for (var product in products) {
                              final category = product.category.isNotEmpty ? product.category : 'Général';
                              if (!groupedProducts.containsKey(category)) {
                                groupedProducts[category] = [];
                              }
                              groupedProducts[category]!.add(product);
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: groupedProducts.entries.map((entry) {
                                return _buildMenuSection(
                                  entry.key,
                                  entry.value.map((product) {
                                    return MenuItemCard(
                                      id: product.id,
                                      restaurantId: product.restaurantId,
                                      title: product.name,
                                      description: product.description,
                                      price: product.price.toString(),
                                      imageUrl: product.imageUrl,
                                      isAvailable: product.isAvailable,
                                      variants: product.variants,
                                    );
                                  }).toList(),
                                );
                              }).toList(),
                            );
                          },
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (error, stack) => Center(child: Text('Erreur: $error')),
                        ),

                        const SizedBox(height: 16),
                        // Reviews Section
                        const Text("Avis clients", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 16),
                        _buildReviewItem("Ahmed B.", 5, "Excellent restaurant ! Le couscous aux fruits de mer était incroyable. Livraison rapide.", "Il y a 2 jours"),
                        _buildReviewItem("Sarah M.", 4, "Très bon Panuzzo, mais la pâte était un peu trop cuite à mon goût. Je recommande tout de même.", "Il y a 1 semaine"),
                        _buildReviewItem("Mehdi F.", 5, "Le meilleur de Djerba sans aucun doute !", "Il y a 2 semaines"),
                        
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Custom Top Bar overlay
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_back, color: DjerbaTheme.textPrimary),
                  ),
                ),
                  Row(
                    children: [
                      ListenableBuilder(
                        listenable: FavoritesService(),
                        builder: (context, _) {
                          final isFav = FavoritesService().isRestaurantFavorite(widget.name);
                          return GestureDetector(
                            onTap: () => FavoritesService().toggleRestaurant(widget.name),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              child: Icon(
                                isFav ? Icons.favorite : Icons.favorite_border,
                                color: isFav ? Colors.red : DjerbaTheme.textPrimary,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => context.push('/cart'),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: const Icon(Icons.shopping_bag_outlined, color: DjerbaTheme.textPrimary),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: ListenableBuilder(
        listenable: CartService(),
        builder: (context, _) {
          if (CartService().totalItems == 0) return const SizedBox.shrink();
          return SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
              ),
              child: ElevatedButton(
                onPressed: () => context.push('/cart'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DjerbaTheme.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: Colors.black.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                      child: Text("${CartService().totalItems}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    const Text("Voir le panier", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    Text("${CartService().totalPrice} TND", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class SignatureDishCard extends StatelessWidget {
  final String id;
  final String restaurantId;
  final String name;
  final String price;
  final String imageUrl;
  
  const SignatureDishCard({super.key, required this.id, required this.restaurantId, required this.name, required this.price, required this.imageUrl});
  
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: CartService(),
      builder: (context, _) {
        final _quantity = CartService().getQuantity(name);
        return Container(
          width: 140,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withOpacity(0.15)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 110,
                decoration: BoxDecoration(
                  image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(text: price, style: const TextStyle(color: DjerbaTheme.textPrimary, fontWeight: FontWeight.w900, fontSize: 14)),
                              const TextSpan(text: " TND", style: TextStyle(color: DjerbaTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
                            ]
                          ),
                        ),
                        _quantity == 0 ? GestureDetector(
                          onTap: () => CartService().addItem(id, restaurantId, name, double.tryParse(price) ?? 0, imageUrl),
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(color: DjerbaTheme.primaryColor, shape: BoxShape.circle),
                            child: const Icon(Icons.add, color: Colors.white, size: 16),
                          ),
                        ) : Row(
                          children: [
                            GestureDetector(
                              onTap: () => CartService().removeItem(name),
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(color: Colors.white, border: Border.all(color: DjerbaTheme.primaryColor), shape: BoxShape.circle),
                                child: const Icon(Icons.remove, color: DjerbaTheme.primaryColor, size: 14),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Text(_quantity.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                            GestureDetector(
                              onTap: () => CartService().addItem(id, restaurantId, name, double.tryParse(price) ?? 0, imageUrl),
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(color: DjerbaTheme.primaryColor, shape: BoxShape.circle),
                                child: const Icon(Icons.add, color: Colors.white, size: 14),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class MenuItemCard extends StatelessWidget {
  final String id;
  final String restaurantId;
  final String title;
  final String description;
  final String price;
  final String imageUrl;
  final bool isAvailable;
  final List<Map<String, dynamic>> variants;

  const MenuItemCard({
    super.key,
    required this.id,
    required this.restaurantId,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isAvailable = true,
    this.variants = const [],
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([CartService(), FavoritesService()]),
      builder: (context, _) {
        final _quantity = CartService().getTotalQuantityForDish(title);
        final isFav = FavoritesService().isDishFavorite(title);
        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          foregroundDecoration: isAvailable ? null : BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            backgroundBlendMode: BlendMode.saturation,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: NetworkImage(imageUrl), 
                    fit: BoxFit.cover, 
                    colorFilter: isAvailable ? null : const ColorFilter.mode(Colors.grey, BlendMode.saturation)
                  ),
                ),
                child: Stack(
                  children: [
                    if (!isAvailable)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Text("ÉPUISÉ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                      ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () {
                          FavoritesService().toggleDish(title);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            size: 16,
                            color: isFav ? Colors.red : DjerbaTheme.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    if (isAvailable)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => _showCustomizationModal(context),
                          child: Container(
                            decoration: BoxDecoration(color: _quantity > 0 ? Colors.green : DjerbaTheme.primaryColor, shape: BoxShape.circle),
                            padding: const EdgeInsets.all(6),
                            child: Icon(_quantity > 0 ? Icons.check : Icons.add, color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isAvailable ? Colors.black : Colors.grey)),
                    const SizedBox(height: 8),
                    Text(description, style: const TextStyle(color: DjerbaTheme.textSecondary, fontSize: 13, height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (variants.isNotEmpty)
                          Text("À partir de ${variants.first['price']} TND", style: const TextStyle(fontWeight: FontWeight.w900, color: DjerbaTheme.textPrimary))
                        else
                          Text("$price TND", style: const TextStyle(fontWeight: FontWeight.w900, color: DjerbaTheme.textPrimary)),
                        if (_quantity > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () => CartService().removeItem(title),
                                  child: const Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Icon(Icons.remove, size: 16, color: DjerbaTheme.primaryColor),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(_quantity.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () {
                                      if (isAvailable) _showCustomizationModal(context);
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.all(4),
                                      child: Icon(Icons.add, size: 16, color: DjerbaTheme.primaryColor),
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
      },
    );
  }

  void _showCustomizationModal(BuildContext context) {
    String selectedSize = variants.isNotEmpty ? variants.first['name'] : "Normale";
    bool noOnions = false;
    int quantity = 1;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(description, style: const TextStyle(color: DjerbaTheme.textSecondary)),
                    const SizedBox(height: 24),

                    if (variants.isNotEmpty) ...[
                      const Text("Taille", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      ...variants.map((v) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text("${v['name']} (${v['price']} TND)"),
                        trailing: Radio<String>(
                          value: v['name'],
                          groupValue: selectedSize,
                          activeColor: DjerbaTheme.primaryColor,
                          onChanged: (val) => setModalState(() => selectedSize = val!),
                        ),
                      )).toList(),
                    ],
                    const Divider(),
                    
                    const Text("Options (Optionnel)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text("Sans oignons"),
                      activeColor: DjerbaTheme.primaryColor,
                      value: noOnions,
                      onChanged: (val) => setModalState(() => noOnions = val ?? false),
                      controlAffinity: ListTileControlAffinity.trailing,
                    ),
                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  if (quantity > 1) setModalState(() => quantity--);
                                },
                                icon: const Icon(Icons.remove, color: DjerbaTheme.primaryColor),
                              ),
                              Text(quantity.toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              IconButton(
                                onPressed: () => setModalState(() => quantity++),
                                icon: const Icon(Icons.add, color: DjerbaTheme.primaryColor),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              double basePrice = double.tryParse(price) ?? 0;
                              if (variants.isNotEmpty) {
                                final selectedVariant = variants.firstWhere((v) => v['name'] == selectedSize, orElse: () => variants.first);
                                basePrice = (selectedVariant['price'] as num).toDouble();
                              }

                              Map<String, String> options = {
                                "Taille": selectedSize,
                              };
                              if (noOnions) options["Options"] = "Sans oignons";

                              CartService().addItem(id, restaurantId, title, basePrice, imageUrl, description: description, options: options, quantity: quantity);
                              Navigator.pop(context);
                              
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Ajouté au panier !"), backgroundColor: Colors.green),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: DjerbaTheme.primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            ),
                            child: const Text("Ajouter au panier", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
      },
    );
  }
}
