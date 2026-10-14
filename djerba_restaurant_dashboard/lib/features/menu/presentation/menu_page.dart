import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import 'providers.dart';
import '../data/menu_api.dart';
import 'widgets/add_product_dialog.dart';

class MenuPage extends ConsumerWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(menuProductsProvider);
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Menu Manager", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
              ElevatedButton.icon(
                onPressed: () {
                  final restId = ref.read(myRestaurantIdProvider).value;
                  if (restId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez patienter...')));
                    return;
                  }
                  showDialog(
                    context: context,
                    builder: (context) => AddProductDialog(restaurantId: restId),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text("Add New Item"),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: productsAsync.when(
              data: (products) {
                if (products.isEmpty) {
                  return const Center(child: Text("No items in your menu yet.", style: TextStyle(color: Colors.grey, fontSize: 18)));
                }

                final groupedProducts = <String, List<ProductModel>>{};
                for (var product in products) {
                  final cat = product.category;
                  groupedProducts.putIfAbsent(cat, () => []).add(product);
                }

                return ListView.builder(
                  itemCount: groupedProducts.keys.length,
                  itemBuilder: (context, index) {
                    final category = groupedProducts.keys.elementAt(index);
                    final categoryProducts = groupedProducts[category]!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(category, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: DjerbaTheme.primaryColor)),
                        ),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            childAspectRatio: 0.85,
                            crossAxisSpacing: 24,
                            mainAxisSpacing: 24,
                          ),
                          itemCount: categoryProducts.length,
                          itemBuilder: (context, i) {
                            return _buildMenuItemCard(context, ref, categoryProducts[i]);
                          },
                        ),
                        const SizedBox(height: 32),
                      ],
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItemCard(BuildContext context, WidgetRef ref, ProductModel product) {
    final bool isAvailable = product.isAvailable;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    color: isAvailable ? null : Colors.black.withOpacity(0.5),
                    colorBlendMode: isAvailable ? null : BlendMode.darken,
                  ),
                  if (!isAvailable)
                    const Center(
                      child: Text("OUT OF STOCK", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.5)),
                    ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text("${product.price.toStringAsFixed(2)} TND", style: const TextStyle(fontWeight: FontWeight.w900)),
                    ),
                  ),
                ],
              ),
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
                    Expanded(child: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () async {
                        final restId = ref.read(myRestaurantIdProvider).value;
                        if (restId == null) return;
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete Product'),
                            content: const Text('Are you sure you want to delete this product?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          final success = await MenuApi().deleteProduct(restId, product.id);
                          if (success) {
                            ref.invalidate(menuProductsProvider);
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to delete product')));
                            }
                          }
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(product.description, style: const TextStyle(color: DjerbaTheme.textSecondary, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(isAvailable ? "Available" : "Unavailable", style: TextStyle(color: isAvailable ? DjerbaTheme.success : DjerbaTheme.danger, fontWeight: FontWeight.bold, fontSize: 12)),
                    Switch(
                      value: isAvailable,
                      onChanged: (val) async {
                        final restId = ref.read(myRestaurantIdProvider).value;
                        if (restId == null) return;
                        final success = await MenuApi().toggleAvailability(restId, product.id, val);
                        if (success) {
                          ref.invalidate(menuProductsProvider);
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erreur lors de la mise à jour')));
                          }
                        }
                      },
                      activeColor: DjerbaTheme.primaryColor,
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
