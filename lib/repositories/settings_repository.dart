import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  static const String _favoritesKey = 'favorites_list';

  // デフォルトのお気に入り（初回起動用）
  static const List<String> _defaultFavorites = [
    'expense:食費',
    'payment:クレジットカード',
    'payment:PayPay',
  ];

  Future<List<String>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favoritesKey) ?? _defaultFavorites;
  }

  Future<void> saveFavorites(List<String> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, favorites);
  }
}
