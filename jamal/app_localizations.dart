import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  // Translation base (Used Map instead of JSON)
  static final Map<String, Map<String, String>> _localizedValues = {
    'uz': {
      'profile': 'Profil',
      'my_orders': 'Mening buyurtmalarim',
      'favorites': 'Sevimlilar',
      'payment_methods': 'To\'lov usullari',
      'app_language': 'Ilova tili',
      'help': 'Yordam',
      'add_salon': 'Salon qo\'shish',
      'logout': 'Chiqish',
      'logout_confirm': 'Haqiqatan ham ilovadan chiqmoqchimisiz?',
      'yes': 'Ha',
      'no': 'Yo\'q',
      'cancel': 'Bekor qilish',
      'save': 'Saqlash',
    },
    'ar': {
      'profile': 'الملف الشخصي',
      'my_orders': 'طلباتي',
      'favorites': 'المفضلة',
      'payment_methods': 'طرق الدفع',
      'app_language': 'لغة التطبيق',
      'help': 'مساعدة',
      'add_salon': 'إضافة صالون',
      'logout': 'تسجيل خروج',
      'logout_confirm': 'هل أنت متأكد أنك تريد تسجيل الخروج؟',
      'yes': 'نعم',
      'no': 'لا',
      'cancel': 'إلغاء',
      'save': 'حفظ',
    },
    'ja': {
      'profile': 'プロフィール',
      'my_orders': '注文履歴',
      'favorites': 'お気に入り',
      'payment_methods': '支払い方法',
      'app_language': 'アプリの言語',
      'help': 'ヘルプ',
      'add_salon': 'サロンを追加',
      'logout': 'ログアウト',
      'logout_confirm': '本当にログアウトしますか？',
      'yes': 'はい',
      'no': 'いいえ',
      'cancel': 'キャンセル',
      'save': '保存',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['uz', 'ar', 'ja'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}