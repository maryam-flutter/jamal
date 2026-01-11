import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jamal/features/auth/prezentation/register.dart';
import '../../home/presentation/home_page.dart';
import '../../../core/user_session.dart';

const Color _primaryPink = Color(0xFFFF6F91);

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnim;
  late Animation<double> _translateAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _rotationAnim = Tween<double>(begin: 0, end: 20 * pi / 180).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _translateAnim = Tween<double>(begin: 0, end: 45).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward(); // Animatsiyani boshlash
    _checkSessionAndNavigate();
  }

  Future<void> _checkSessionAndNavigate() async {
    // Foydalanuvchi ma'lumotlarini xotiradan yuklashni kutamiz
    await UserSession().init();

    // Splash screen uchun minimal vaqtni kutamiz
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      // Foydalanuvchi avval ro'yxatdan o'tganligini tekshiramiz
      final destinationPage =
          UserSession().userName != null ? const HomePage() : const RegisterPage();

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => destinationPage),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _primaryPink,
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 120),
              child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return SizedBox(
                  height: 400, // Kartalar joylashadigan umumiy balandlik
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // 1-karta: Chapga og'gan (Orqada)
                      Transform(
                        alignment: Alignment.bottomCenter,
                        transform: Matrix4.identity()
                          ..translate(-_translateAnim.value, 20.0) // Chapga va pastga surish
                          ..rotateZ(-_rotationAnim.value), // -15 gradusga aylantirish
                        child: _buildImageCard('assets/oo.png'),
                      ),
                      
                      // 2-karta: O'ngga og'gan (Orqada)
                      Transform(
                        alignment: Alignment.bottomCenter,
                        transform: Matrix4.identity()
                          ..translate(_translateAnim.value, 20.0) // O'ngga va pastga surish
                          ..rotateZ(_rotationAnim.value), // 15 gradusga aylantirish
                        child: _buildImageCard('assets/ss.png'),
                      ),
                      
                      // 3-karta: Markazda (Oldinda)
                      Transform(
                        alignment: Alignment.bottomCenter,
                        transform: Matrix4.identity()
                          ..translate(0.0, -20.0 * _controller.value), // Biroz yuqoriga ko'tarish
                        child: _buildImageCard('assets/ii.png'),
                      ),
                    ],
                  ),
                );
              },
            ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  'Jamal',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Professional parvarish endi yaqinroq',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCard(String imagePath) {
    return Container(
      width: 180,
      height: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.white, width: 5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFFF0F5), Colors.white],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}