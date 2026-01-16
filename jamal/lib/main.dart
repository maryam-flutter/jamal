import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:jamal/core/app_localizations.dart';
import 'package:jamal/core/booking_store.dart';
import 'package:jamal/core/favorites_store.dart';
import 'package:jamal/core/user_session.dart';
import 'package:jamal/features/auth/prezentation/splash_screen.dart';
import 'package:jamal/features/home/data/salon_store.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = _AppHttpOverrides();
  // Ilova ishga tushishidan oldin sessiya va til sozlamalarini yuklaymiz
  await UserSession().init();
  await BookingStore().init();
  await FavoritesStore().init();
  await SalonStore().init();
  runApp(const MyApp());
}

class _AppHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.userAgent = 'Mozilla/5.0';
    return client;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // UserSession.languageNotifier ga quloq solamiz
    return ValueListenableBuilder<Locale>(
      valueListenable: UserSession().languageNotifier,
      builder: (context, locale, child) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: UserSession().themeNotifier,
          builder: (context, themeMode, child) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Jamal Beauty',
              theme: ThemeData(
                primarySwatch: Colors.pink,
                useMaterial3: true,
                scaffoldBackgroundColor: Colors.white,
                appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  elevation: 0,
                ),
              ),
              darkTheme: ThemeData(
                brightness: Brightness.dark,
                useMaterial3: true,
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink, brightness: Brightness.dark).copyWith(
                  surface: const Color(0xFF333333),
                  background: const Color(0xFF2A2A2A),
                ),
                scaffoldBackgroundColor: const Color(0xFF2A2A2A),
                appBarTheme: const AppBarTheme(
                  backgroundColor: Color(0xFF333333),
                  foregroundColor: Colors.white,
                ),
              ),
              themeMode: themeMode,
              // Til sozlamalari
              locale: locale,
              supportedLocales: const [
                Locale('uz'),
                Locale('ru'),
                Locale('en'),
                Locale('ar'),
              ],
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: const SplashScreen(),
            );
          },
        );
      },
    );
  }
}
