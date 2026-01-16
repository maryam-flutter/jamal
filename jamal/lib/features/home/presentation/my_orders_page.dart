import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/app_fonts.dart';
import '../../../core/app_localizations.dart';
import '../../../core/booking_store.dart';

class MyOrdersPage extends StatelessWidget {
  const MyOrdersPage({Key? key}) : super(key: key);

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
          t.translate('my_orders_title'),
          style: AppFonts.plusJakartaSans(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: ValueListenableBuilder<List<Booking>>(
        valueListenable: BookingStore().bookings,
        builder: (context, bookings, child) {
          if (bookings.isEmpty) {
            return Center(
              child: Text(
                t.translate('my_orders_empty'),
                style: AppFonts.plusJakartaSans(color: Colors.grey[500], fontSize: 16, fontWeight: FontWeight.w600),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              final isActive = booking.status == 'active';
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFF6F8), Color(0xFFFFE3EA), Color(0xFFFFFFFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${t.translate('order_label')} #${1023 + index}',
                        style: AppFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.black87),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isActive ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isActive ? t.translate('order_status_active') : t.translate('order_status_completed'),
                            style: AppFonts.plusJakartaSans(
                              color: isActive ? Colors.green : Colors.grey,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey[200],
                            image: DecorationImage(image: _bookingImageProvider(booking.salonImage), fit: BoxFit.cover),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t.translate(booking.salonName),
                                style: AppFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: Colors.black87),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_serviceTitle(t, booking)} - ${_dateLabel(t, booking)}, ${booking.timeLabel}',
                                style: AppFonts.plusJakartaSans(color: Colors.black54, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          _priceLabel(t, booking),
                          style: AppFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.black87),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _serviceTitle(AppLocalizations t, Booking booking) {
    final key = booking.serviceTitleKey;
    if (key != null && key.isNotEmpty) {
      return t.translate(key);
    }
    return booking.serviceTitle;
  }

  String _priceLabel(AppLocalizations t, Booking booking) {
    final key = booking.priceKey;
    if (key != null && key.isNotEmpty) {
      return t.translate(key);
    }
    return booking.priceLabel;
  }

  String _dateLabel(AppLocalizations t, Booking booking) {
    final epoch = booking.dateEpoch;
    if (epoch == null) {
      return booking.dateLabel;
    }
    final date = DateTime.fromMillisecondsSinceEpoch(epoch);
    return _formatDate(t, date);
  }

  String _formatDate(AppLocalizations t, DateTime date) {
    final months = [
      '',
      t.translate('month_jan'),
      t.translate('month_feb'),
      t.translate('month_mar'),
      t.translate('month_apr'),
      t.translate('month_may'),
      t.translate('month_jun'),
      t.translate('month_jul'),
      t.translate('month_aug'),
      t.translate('month_sep'),
      t.translate('month_oct'),
      t.translate('month_nov'),
      t.translate('month_dec'),
    ];
    final month = (date.month >= 0 && date.month < months.length) ? months[date.month] : '';
    return '${date.day} $month';
  }
}

ImageProvider _bookingImageProvider(String path) {
  if (path.startsWith('http://') || path.startsWith('https://')) {
    return NetworkImage(path, headers: const {'User-Agent': 'Mozilla/5.0'});
  }
  if (path.startsWith('assets/')) {
    return AssetImage(path);
  }
  final file = File(path);
  if (file.existsSync()) {
    return FileImage(file);
  }
  return const AssetImage('assets/salon.png');
}
