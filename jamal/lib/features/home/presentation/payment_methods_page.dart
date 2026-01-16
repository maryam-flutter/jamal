import 'package:flutter/material.dart';
import '../../../core/app_fonts.dart';
import '../../../core/app_localizations.dart';

class PaymentMethodsPage extends StatelessWidget {
  const PaymentMethodsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
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
          t.translate('payment_methods_title'),
          style: AppFonts.plusJakartaSans(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.credit_card_off_rounded, size: 80, color: colorScheme.onSurface.withOpacity(0.3)),
            const SizedBox(height: 24),
            Text(
              t.translate('payment_methods_coming_soon'),
              style: AppFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w800, color: colorScheme.onSurface),
            ),
            const SizedBox(height: 8),
            Text(
              t.translate('payment_methods_description'),
              style: AppFonts.plusJakartaSans(color: colorScheme.onSurface.withOpacity(0.6), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

