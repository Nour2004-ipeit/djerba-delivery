import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import 'favorites_service.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: DjerbaTheme.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text("Mes Favoris", style: TextStyle(color: DjerbaTheme.textPrimary, fontWeight: FontWeight.w900, fontSize: 20)),
        centerTitle: true,
      ),
      body: ListenableBuilder(
        listenable: FavoritesService(),
        builder: (context, _) {
          final favRestaurants = FavoritesService().favoriteRestaurants;
          final favDishes = FavoritesService().favoriteDishes;

          if (favRestaurants.isEmpty && favDishes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text("Aucun favori pour le moment", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (favRestaurants.isNotEmpty) ...[
                  const Text("Restaurants", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 16),
                  ...favRestaurants.map((name) => _buildFavItem(name, true, context)),
                  const SizedBox(height: 24),
                ],
                if (favDishes.isNotEmpty) ...[
                  const Text("Plats", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 16),
                  ...favDishes.map((name) => _buildFavItem(name, false, context)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFavItem(String name, bool isRestaurant, BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isRestaurant) {
          // Navigate to the restaurant detail screen
          context.push('/restaurant_detail', extra: {
            'name': name,
            'imageUrl': 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&q=80&w=800', // Using a generic placeholder since we don't have the original image URL saved in FavoritesService
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade200,
            ),
            child: Icon(isRestaurant ? Icons.store : Icons.fastfood, color: Colors.grey.shade400),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.red),
            onPressed: () {
              if (isRestaurant) {
                FavoritesService().toggleRestaurant(name);
              } else {
                FavoritesService().toggleDish(name);
              }
            },
          ),
        ],
      ),
      ),
    );
  }
}
