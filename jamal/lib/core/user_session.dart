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

  String? userName;
  String? userPhone;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    userName = prefs.getString('userName');
    userPhone = prefs.getString('userPhone');
    
    // Saqlangan tilni yuklash
    final langCode = prefs.getString('language_code') ?? 'uz';
    languageNotifier.value = Locale(langCode);
  }

  Future<void> saveUser(String name, String phone) async {
    userName = name;
    userPhone = phone;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', name);
    await prefs.setString('userPhone', phone);
  }

  Future<void> saveLanguage(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', langCode);
    languageNotifier.value = Locale(langCode);
  }

  Future<void> clear() async {
    userName = null;
    userPhone = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userName');
    await prefs.remove('userPhone');
  }
}