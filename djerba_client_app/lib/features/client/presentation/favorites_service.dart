import 'package:flutter/foundation.dart';

class FavoritesService extends ChangeNotifier {
  static final FavoritesService _instance = FavoritesService._internal();
  
  factory FavoritesService() {
    return _instance;
  }
  
  FavoritesService._internal();

  final Set<String> _favoriteRestaurants = {};
  final Set<String> _favoriteDishes = {};

  Set<String> get favoriteRestaurants => _favoriteRestaurants;
  Set<String> get favoriteDishes => _favoriteDishes;

  void toggleRestaurant(String name) {
    if (_favoriteRestaurants.contains(name)) {
      _favoriteRestaurants.remove(name);
    } else {
      _favoriteRestaurants.add(name);
    }
    notifyListeners();
  }

  bool isRestaurantFavorite(String name) {
    return _favoriteRestaurants.contains(name);
  }

  void toggleDish(String name) {
    if (_favoriteDishes.contains(name)) {
      _favoriteDishes.remove(name);
    } else {
      _favoriteDishes.add(name);
    }
    notifyListeners();
  }

  bool isDishFavorite(String name) {
    return _favoriteDishes.contains(name);
  }
}
