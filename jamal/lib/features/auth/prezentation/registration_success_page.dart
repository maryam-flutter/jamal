import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../home/presentation/home_page.dart';

const Color _successPink = Color(0xFFFF6F91);

class RegistrationSuccessPage extends StatefulWidget {
  final dynamic userId;

  const RegistrationSuccessPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<RegistrationSuccessPage> createState() => _RegistrationSuccessPageState();
}

class _RegistrationSuccessPageState extends State<RegistrationSuccessPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, size: 96, color: _successPink),
              const SizedBox(height: 18),
              Text(
                "Ro'yxatdan muvaffaqiyatli o'tdingiz",
                style: GoogleFonts.plusJakartaSans(
                  textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
