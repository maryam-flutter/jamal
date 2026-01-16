import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesStore {
  static final FavoritesStore _instance = FavoritesStore._internal();

  factory FavoritesStore() {
    return _instance;
  }

  FavoritesStore._internal();

  static const String _storageKey = 'favorite_salons';

  final ValueNotifier<Set<String>> favorites = ValueNotifier(<String>{});

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_storageKey) ?? <String>[];
    favorites.value = stored.toSet();
  }

  bool isFavorite(String salonId) {
    return favorites.value.contains(salonId);
  }

  Future<void> toggleFavorite(String salonId) async {
    final next = Set<String>.from(favorites.value);
    if (next.contains(salonId)) {
      next.remove(salonId);
    } else {
      next.add(salonId);
    }
    favorites.value = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_storageKey, next.toList());
  }
}
