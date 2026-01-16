import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  static final UserSession _instance = UserSession._internal();

  factory UserSession() {
    return _instance;
  }

  UserSession._internal();

  // Til o'zgarishini kuzatuvchi (Default: o'zbekcha)
  final ValueNotifier<Locale> languageNotifier = ValueNotifier(const Locale('uz'));
  final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

  String? userId;
  String? userName;
  String? userPhone;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');
    userName = prefs.getString('userName');
    userPhone = prefs.getString('userPhone');
    
    // Saqlangan tilni yuklash
    final langCode = prefs.getString('language_code') ?? 'uz';
    languageNotifier.value = Locale(langCode);

    final themeCode = prefs.getString('theme_mode') ?? 'light';
    themeNotifier.value = themeCode == 'dark' ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> saveUser(String name, String phone, {String? id}) async {
    userId = id;
    userName = name;
    userPhone = phone;
    final prefs = await SharedPreferences.getInstance();
    if (id != null) {
      await prefs.setString('userId', id);
    }
    await prefs.setString('userName', name);
    await prefs.setString('userPhone', phone);
  }

  Future<void> saveLanguage(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', langCode);
    languageNotifier.value = Locale(langCode);
  }

  Future<void> saveTheme(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', mode == ThemeMode.dark ? 'dark' : 'light');
    themeNotifier.value = mode;
  }

  Future<void> clear() async {
    userId = null;
    userName = null;
    userPhone = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('userName');
    await prefs.remove('userPhone');
  }
}
