class FavoritesRepository {
  static final Set<String> _favorites = {};

  List<String> getFavorites() {
    return _favorites.toList();
  }

  bool isFavorite(String name) {
    return _favorites.contains(name);
  }

  void toggleFavorite(String name) {
    if (_favorites.contains(name)) {
      _favorites.remove(name);
    } else {
      _favorites.add(name);
    }
  }
}
