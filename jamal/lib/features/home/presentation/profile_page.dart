import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../auth/prezentation/register.dart';
import '../../../core/user_session.dart';
import '../../../core/app_localizations.dart';
import 'my_orders_page.dart';
import 'favorites_page.dart';
import 'payment_methods_page.dart';
import 'language_page.dart';
import 'support_chat_page.dart';
import 'add_salon_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
    // If data is missing in memory (e.g., when app is updated), reload them
    if (UserSession().userName == null) {
      UserSession().init().then((_) => setState(() {}));
    }
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('profile_image_path');
    if (path != null && File(path).existsSync()) {
      setState(() {
        _profileImage = File(path);
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image_path', pickedFile.path);
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryPink = Color(0xFFFF6F91);
    final t = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header section: White background, shadow, and rounded corners
            Container(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        t?.translate('profile') ?? 'Profil',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.settings_outlined, color: Colors.black),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Avatar and edit button
                  GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: primaryPink.withOpacity(0.3), width: 1),
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: _profileImage != null
                              ? FileImage(_profileImage!) as ImageProvider
                              : const AssetImage('assets/images/profile.png'),
                          onBackgroundImageError: (_, __) {},
                          child: _profileImage == null ? const Icon(Icons.person, size: 50, color: Colors.grey) : null,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit, color: Colors.white, size: 16),
                      ),
                    ],
                  ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    UserSession().userName ?? (t?.translate('user_default') ?? 'Foydalanuvchi'),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    UserSession().userPhone ?? (t?.translate('no_phone') ?? 'Raqam kiritilmagan'),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Menyu elementlari
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildMenuItem(context, Icons.calendar_month_rounded, t?.translate('my_orders') ?? 'Mening buyurtmalarim', primaryPink, onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const MyOrdersPage()));
                  }),
                  _buildMenuItem(context, Icons.favorite_rounded, t?.translate('favorites') ?? 'Sevimlilar', primaryPink, onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesPage()));
                  }),
                  _buildMenuItem(context, Icons.credit_card_rounded, t?.translate('payment_methods') ?? 'To\'lov usullari', primaryPink, onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentMethodsPage()));
                  }),
                  _buildMenuItem(context, Icons.language_rounded, t?.translate('app_language') ?? 'Ilova tili', primaryPink, onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const LanguagePage()));
                  }),
                  _buildMenuItem(context, Icons.headset_mic_rounded, t?.translate('help') ?? 'Yordam', primaryPink, onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportChatPage()));
                  }),
                  _buildMenuItem(context, Icons.store_rounded, t?.translate('add_salon') ?? 'Salon qo\'shish', primaryPink, onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AddSalonPage()));
                  }),
                  const SizedBox(height: 20),
                  _buildMenuItem(context, Icons.logout_rounded, t?.translate('logout') ?? 'Chiqish', Colors.red[400]!, isLogout: true, onTap: () {
                    _showLogoutDialog(context);
                  }),
                ],
              ),
            ),
            const SizedBox(height: 100), // Space for bottom menu
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final t = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t?.translate('logout') ?? 'Chiqish'),
        content: Text(t?.translate('logout_confirm') ?? 'Haqiqatan ham ilovadan chiqmoqchimisiz?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(t?.translate('no') ?? 'Yo\'q')),
          TextButton(onPressed: () async {
             await UserSession().clear(); // Clear data
             if (context.mounted) {
               Navigator.of(context).pushAndRemoveUntil(
                 MaterialPageRoute(builder: (_) => const RegisterPage()), // Return to registration
                 (route) => false,
               );
             }
          }, child: Text(t?.translate('yes') ?? 'Ha', style: const TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, Color color, {bool isLogout = false, VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isLogout ? Colors.red[50] : color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: isLogout ? Colors.red[400] : Colors.black87,
          ),
        ),
        trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey[300]),
        onTap: onTap,
      ),
    );
  }
}