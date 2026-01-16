import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/app_fonts.dart';
import '../../../core/app_localizations.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _isCleared = false;

  @override
  Widget build(BuildContext context) {
    const primaryPink = Color(0xFFFF6F91);
    final t = AppLocalizations.of(context)!;

    final notifications = _isCleared
        ? <Map<String, Object>>[]
        : [
            {
              'title': t.translate('notification_order_confirmed_title'),
              'body': t.translate('notification_order_confirmed_body'),
              'time': t.translate('notifications_time_now'),
              'icon': Icons.check_circle_outline,
              'color': Colors.green,
            },
            {
              'title': t.translate('notification_special_offer_title'),
              'body': t.translate('notification_special_offer_body'),
              'time': t.translate('notifications_time_2h'),
              'icon': Icons.local_offer_outlined,
              'color': primaryPink,
            },
            {
              'title': t.translate('notification_reminder_title'),
              'body': t.translate('notification_reminder_body'),
              'time': t.translate('notifications_time_yesterday'),
              'icon': Icons.access_time,
              'color': Colors.orange,
            },
          ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFF6F8), Color(0xFFFFC8D3), Color(0xFFFFFFFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    t.translate('notifications_title'),
                    style: AppFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _isCleared = true),
                    child: Text(
                      t.translate('notifications_clear'),
                      style: AppFonts.plusJakartaSans(
                        color: primaryPink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final item = notifications[index];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFF7FA), Color(0xFFFFE1EA), Color(0xFFFFFFFF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 14,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: (item['color'] as Color).withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(item['icon'] as IconData, color: item['color'] as Color, size: 24),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        item['title'] as String,
                                        style: AppFonts.plusJakartaSans(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      Text(
                                        item['time'] as String,
                                        style: AppFonts.plusJakartaSans(
                                          color: Colors.black54,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item['body'] as String,
                                    style: AppFonts.plusJakartaSans(
                                      color: Colors.black54,
                                      fontSize: 14,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
