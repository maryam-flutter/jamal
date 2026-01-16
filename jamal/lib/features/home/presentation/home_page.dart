import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/app_fonts.dart';
import '../../../core/app_localizations.dart';
import 'home_content_page.dart';
import 'notifications_page.dart';
import 'profile_page.dart';
import 'search_page.dart';

const Color _primaryPink = Color(0xFFFF6F91);

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  int _activeIndex = 0;
  int _rippleIndex = 0;

  late final AnimationController _rippleController;

  final iconList = <IconData>[
    Icons.home,
    Icons.search,
    Icons.notifications,
    Icons.person,
  ];

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
  }

  @override
  void dispose() {
    _rippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final labels = [
      t.translate('nav_home'),
      t.translate('nav_search'),
      t.translate('nav_notifications'),
      t.translate('nav_profile'),
    ];
    // Sahifalar ro'yxati: 0-Home, 1-Search, 2-Notifications, 3-Profile
    final pages = [
      HomeContentPage(),
      const SearchPage(),
      const NotificationsPage(),
      ProfilePage(),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBody: true,
      body: pages[_activeIndex],
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: SizedBox(
            height: 72,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFF6F8), Color(0xFFFFE3EA), Color(0xFFFFFFFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.6), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                    ),
                  ],
                ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final itemWidth = constraints.maxWidth / iconList.length;
                      return Stack(
                    children: [
                      AnimatedBuilder(
                        animation: _rippleController,
                        builder: (context, child) {
                          final centerX = _rippleIndex * itemWidth + (itemWidth / 2);
                          final scale = 1.0 + (1.6 * _rippleController.value);
                          final opacity = (1.0 - _rippleController.value) * 0.35;
                          return Positioned(
                            left: centerX - 12,
                            top: 6,
                            child: Opacity(
                              opacity: opacity,
                              child: Transform.scale(
                                scale: scale,
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: _primaryPink,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: List.generate(iconList.length, (index) {
                                final isActive = _activeIndex == index;
                                final color = isActive ? _primaryPink : Colors.grey;
                                return InkResponse(
                                  onTap: () {
                                    setState(() {
                                      _activeIndex = index;
                                      _rippleIndex = index;
                                    });
                                    _rippleController.forward(from: 0);
                                  },
                                  radius: 28,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(iconList[index], color: color, size: 22),
                                      const SizedBox(height: 4),
                                      Text(
                                        labels[index],
                                        style: AppFonts.plusJakartaSans(
                                          fontSize: 11,
                                          fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                                          color: color,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                      ),
                    ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
