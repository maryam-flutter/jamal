import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentMethodsPage extends StatelessWidget {
  const PaymentMethodsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'To\'lov usullari',
          style: GoogleFonts.plusJakartaSans(color: Colors.black, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.credit_card_off_rounded, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 24),
            Text(
              'Tez orada...',
              style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.black),
            ),
            const SizedBox(height: 8),
            Text(
              'Ushbu bo\'lim ustida ish olib borilmoqda',
              style: GoogleFonts.plusJakartaSans(color: Colors.grey[500], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}