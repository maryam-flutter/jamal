import 'package:flutter/material.dart';
import '../../../core/app_fonts.dart';
import '../../../core/app_localizations.dart';
import '../../../core/user_session.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
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
          t?.translate('settings_title') ?? 'Settings',
          style: AppFonts.plusJakartaSans(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ValueListenableBuilder<ThemeMode>(
            valueListenable: UserSession().themeNotifier,
            builder: (context, mode, child) {
              final isDark = mode == ThemeMode.dark;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    t?.translate('dark_mode') ?? 'Dark mode',
                    style: AppFonts.plusJakartaSans(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Switch(
                    value: isDark,
                    activeColor: const Color(0xFFFF6F91),
                    onChanged: (value) {
                      UserSession().saveTheme(value ? ThemeMode.dark : ThemeMode.light);
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
