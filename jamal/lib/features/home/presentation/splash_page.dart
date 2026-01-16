import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/app_fonts.dart';
import 'home_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
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

    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ilovaning asosiy rangi
    const primaryPink = Color(0xFFFF6F91);

    return Scaffold(
      backgroundColor: primaryPink,
      body: Stack(
        children: [
          Center(
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
                        child: _buildImageCard(),
                      ),
                      
                      // 2-karta: O'ngga og'gan (Orqada)
                      Transform(
                        alignment: Alignment.bottomCenter,
                        transform: Matrix4.identity()
                          ..translate(_translateAnim.value, 20.0) // O'ngga va pastga surish
                          ..rotateZ(_rotationAnim.value), // 15 gradusga aylantirish
                        child: _buildImageCard(),
                      ),
                      
                      // 3-karta: Markazda (Oldinda)
                      Transform(
                        alignment: Alignment.bottomCenter,
                        transform: Matrix4.identity()
                          ..translate(0.0, -20.0 * _controller.value), // Biroz yuqoriga ko'tarish
                        child: _buildImageCard(),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  'Jamal',
                  style: AppFonts.plusJakartaSans(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'v1.0.0',
                  style: AppFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCard() {
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
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFF0F5), Colors.white],
            ),
          ),
        ),
      ),
    );
  }
}
