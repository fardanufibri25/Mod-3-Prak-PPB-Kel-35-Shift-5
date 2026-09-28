import 'package:flutter_test/flutter_test.dart';
import 'package:mod_3_kel35/models/country.dart';
import 'package:mod_3_kel35/services/favorites_manager.dart';

void main() {
  test('FavoritesManager toggles and removes favorites correctly', () {
    final manager = FavoritesManager();
    final country = Country(
      name: 'Indonesia',
      region: 'Asia',
      population: 273523615,
      capital: 'Jakarta',
    );

    // Initial state: not favorite
    expect(manager.isFavorite(country), isFalse);

    // Add to favorites
    final added = manager.toggleFavorite(country);
    expect(added, isTrue);
    expect(manager.isFavorite(country), isTrue);
    expect(manager.favorites.length, 1);

    // Remove from favorites via toggle
    final removed = manager.toggleFavorite(country);
    expect(removed, isFalse);
    expect(manager.isFavorite(country), isFalse);
    expect(manager.favorites.isEmpty, isTrue);

    // Re-add and remove via removeFavorite
    manager.toggleFavorite(country);
    expect(manager.isFavorite(country), isTrue);
    manager.removeFavorite(country);
    expect(manager.isFavorite(country), isFalse);
  });
}
