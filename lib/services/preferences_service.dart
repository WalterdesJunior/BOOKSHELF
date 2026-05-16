import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static final PreferencesService _instance = PreferencesService._internal();
  factory PreferencesService() => _instance;
  PreferencesService._internal();

  static const _keyCategory = 'pref_category';
  static const _keyBrasil = 'pref_brasil';

  Future<String> getDefaultCategory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCategory) ?? 'Geral';
  }

  Future<void> setDefaultCategory(String category) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCategory, category);
  }

  Future<bool> getBrasilMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyBrasil) ?? true;
  }

  Future<void> setBrasilMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyBrasil, value);
  }
}
