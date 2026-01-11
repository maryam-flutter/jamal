import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:jamal/core/app_localizations.dart';
import 'package:jamal/core/user_session.dart';
import 'package:jamal/features/auth/prezentation/register.dart';
import 'package:jamal/features/home/presentation/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Ilova ishga tushishidan oldin sessiya va til sozlamalarini yuklaymiz
  await UserSession().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // UserSession.languageNotifier ga quloq solamiz
    return ValueListenableBuilder<Locale>(
      valueListenable: UserSession().languageNotifier,
      builder: (context, locale, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Jamal Beauty',
          theme: ThemeData(
            primarySwatch: Colors.pink,
            useMaterial3: true,
            scaffoldBackgroundColor: Colors.grey[50],
          ),
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
          home: UserSession().userName != null ? const HomePage() : const RegisterPage(),
        );
      },
    );
  }
}