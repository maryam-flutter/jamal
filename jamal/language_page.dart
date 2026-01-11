import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({Key? key}) : super(key: key);

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  String _currentLang = 'uz';

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentLang = prefs.getString('language_code') ?? 'uz';
    });
  }

  Future<void> _setLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', code);
    setState(() {
      _currentLang = code;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Til o\'zgartirildi. Ilovani qayta ishga tushiring.'),
          backgroundColor: Colors.grey[800],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Ilova tili', style: GoogleFonts.plusJakartaSans(color: Colors.black, fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
            _buildLanguageItem('O\'zbekcha', 'uz', '🇺🇿'),
            _buildLanguageItem('العربية', 'ar', '🇦🇪'),
            _buildLanguageItem('日本語 (Tokyo)', 'ja', '🇯🇵'),
        ],
      ),
    );
  }

  Widget _buildLanguageItem(String name, String code, String flag) {
      final isSelected = _currentLang == code;
      return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: isSelected ? Border.all(color: const Color(0xFFFF6F91), width: 2) : null,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
          ),
          child: ListTile(
              leading: Text(flag, style: const TextStyle(fontSize: 24)),
              title: Text(name, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
              trailing: isSelected ? const Icon(Icons.check_circle, color: Color(0xFFFF6F91)) : null,
              onTap: () => _setLanguage(code),
          ),
      );
  }
}