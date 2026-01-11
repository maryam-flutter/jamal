import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:google_fonts/google_fonts.dart';
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

class _HomePageState extends State<HomePage> {
  int _activeIndex = 0;

  final iconList = <IconData>[
    Icons.home,
    Icons.search,
    Icons.notifications,
    Icons.person,
  ];

  @override
  Widget build(BuildContext context) {
    // Sahifalar ro'yxati: 0-Home, 1-Search, 2-Notifications, 3-Profile
    final pages = [
      HomeContentPage(),
      const SearchPage(),
      const NotificationsPage(),
      ProfilePage(),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      extendBody: true,
      body: pages[_activeIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: _primaryPink,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: SafeArea(
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
            child: Container(
              color: Colors.white.withOpacity(0.10),
              child: AnimatedBottomNavigationBar(
                icons: iconList,
                activeIndex: _activeIndex,
                gapLocation: GapLocation.center,
                notchSmoothness: NotchSmoothness.smoothEdge,
                onTap: (index) => setState(() => _activeIndex = index),
                // All nav icons are black; the central FAB is styled pink
                activeColor: _primaryPink,
                inactiveColor: Colors.grey,
                height: 60,
              ),
            ),
          ),
        ),
      ),
    );
  }
}