import 'package:flutter/material.dart';
import '../../../core/app_fonts.dart';
import '../../../core/app_localizations.dart';
import '../../../core/user_session.dart';

class LanguagePage extends StatelessWidget {
  const LanguagePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          t.translate('app_language'),
          style: AppFonts.plusJakartaSans(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: ValueListenableBuilder<Locale>(
        valueListenable: UserSession().languageNotifier,
        builder: (context, locale, child) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildLanguageItem(context, 'O\'zbekcha', 'uz', locale.languageCode == 'uz'),
              _buildLanguageItem(context, '\u0420\u0443\u0441\u0441\u043a\u0438\u0439', 'ru', locale.languageCode == 'ru'),
              _buildLanguageItem(context, 'English', 'en', locale.languageCode == 'en'),
              _buildLanguageItem(context, '\u0627\u0644\u0639\u0631\u0628\u064a\u0629', 'ar', locale.languageCode == 'ar'),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLanguageItem(BuildContext context, String name, String code, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isSelected ? Border.all(color: const Color(0xFFFF6F91), width: 2) : null,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        title: Text(
          name,
          style: AppFonts.plusJakartaSans(
            fontWeight: FontWeight.w600,
            color: isSelected ? const Color(0xFFFF6F91) : Colors.black87,
          ),
        ),
        trailing: isSelected
            ? const Icon(Icons.check_circle_rounded, color: Color(0xFFFF6F91))
            : null,
        onTap: () {
          UserSession().saveLanguage(code);
        },
      ),
    );
  }
}
