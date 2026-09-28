import 'package:flutter/foundation.dart';
import '../models/country.dart';

class FavoritesManager {
  static final FavoritesManager _instance = FavoritesManager._internal();
  factory FavoritesManager() => _instance;
  FavoritesManager._internal();

  final ValueNotifier<List<Country>> favoritesNotifier = ValueNotifier<List<Country>>([]);

  List<Country> get favorites => favoritesNotifier.value;

  bool isFavorite(Country country) {
    return favoritesNotifier.value.any((item) => item.name == country.name);
  }

  /// Returns true if added, false if removed
  bool toggleFavorite(Country country) {
    final currentList = List<Country>.from(favoritesNotifier.value);
    final exists = currentList.any((item) => item.name == country.name);

    if (exists) {
      currentList.removeWhere((item) => item.name == country.name);
      favoritesNotifier.value = currentList;
      return false;
    } else {
      currentList.add(country);
      favoritesNotifier.value = currentList;
      return true;
    }
  }

  void removeFavorite(Country country) {
    final currentList = List<Country>.from(favoritesNotifier.value);
    currentList.removeWhere((item) => item.name == country.name);
    favoritesNotifier.value = currentList;
  }
}
