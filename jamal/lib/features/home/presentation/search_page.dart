import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/app_fonts.dart';
import '../../../core/app_localizations.dart';
import '../data/salon_repository.dart';
import 'salon_detail_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String? _selectedCategoryKey;

  @override
  void initState() {
    super.initState();
    _selectedCategoryKey = 'category_hair';
  }

  @override
  Widget build(BuildContext context) {
    const primaryPink = Color(0xFFFF6F91);
    final t = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final categories = [
      {'key': 'category_hair', 'icon': Icons.content_cut, 'name': t.translate('category_hair')},
      {'key': 'category_makeup', 'icon': Icons.brush, 'name': t.translate('category_makeup')},
      {'key': 'category_spa', 'icon': Icons.spa, 'name': t.translate('category_spa')},
      {'key': 'category_face', 'icon': Icons.face, 'name': t.translate('category_face')},
      {'key': 'category_manicure', 'icon': Icons.back_hand, 'name': t.translate('category_manicure')},
    ];

    final selectedKey = _selectedCategoryKey ?? categories.first['key'] as String;
    final services = SalonRepository.getServicesByCategory(selectedKey);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Search Header
            ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFF7FA), Color(0xFFFFE1EA), Color(0xFFFFFFFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.5), width: 1)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.translate('search_title'),
                        style: AppFonts.plusJakartaSans(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white : colorScheme.surface.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.7), width: 1),
                        ),
                        child: TextField(
                          style: const TextStyle(color: Colors.black87),
                          decoration: InputDecoration(
                            hintText: t.translate('search_hint'),
                            hintStyle: AppFonts.plusJakartaSans(color: Colors.black54),
                            prefixIcon: const Icon(Icons.search, color: primaryPink),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.translate('search_categories'),
                      style: AppFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 100,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final cat = categories[index];
                          final key = cat['key'] as String;
                          final isSelected = key == selectedKey;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedCategoryKey = key),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                child: Container(
                                  width: 80,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: isSelected
                                          ? [const Color(0xFFFFC3D2), const Color(0xFFFFE1EA)]
                                          : const [Color(0xFFFFF7FA), Color(0xFFFFE1EA), Color(0xFFFFFFFF)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: primaryPink.withOpacity(0.12),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(cat['icon'] as IconData, color: primaryPink, size: 24),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        cat['name'] as String,
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppFonts.plusJakartaSans(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      t.translate('salon_services_title'),
                      style: AppFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (services.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 6))],
                        ),
                        child: Text(
                          t.translate('no_services_yet'),
                          style: AppFonts.plusJakartaSans(color: colorScheme.onSurface.withOpacity(0.6), fontWeight: FontWeight.w600),
                        ),
                      )
                    else
                      ListView.separated(
                        itemCount: services.length,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final service = services[index];
                          final salon = SalonRepository.getSalonById(service.salonId);
                          return _ServiceCard(
                            title: t.translate(service.titleKey),
                            duration: t.translate(service.durationKey),
                            price: t.translate(service.priceKey),
                            salonName: salon == null ? t.translate('salon_name_fallback') : t.translate(salon.name),
                            onTap: salon == null
                                ? null
                                : () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => SalonDetailPage(salon: salon)),
                                    );
                                  },
                          );
                        },
                      ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final String title;
  final String duration;
  final String price;
  final String salonName;
  final VoidCallback? onTap;

  const _ServiceCard({
    Key? key,
    required this.title,
    required this.duration,
    required this.price,
    required this.salonName,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFF7FA), Color(0xFFFFE1EA), Color(0xFFFFFFFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 6))],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: const Color(0xFFFF6F91).withOpacity(0.15), shape: BoxShape.circle),
              child: const Icon(Icons.spa_rounded, color: Color(0xFFFF6F91)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.black87)),
                  const SizedBox(height: 4),
                  Text(
                    salonName,
                    style: AppFonts.plusJakartaSans(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(price, style: AppFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 13, color: Colors.black87)),
                const SizedBox(height: 4),
                Text(duration, style: AppFonts.plusJakartaSans(color: Colors.black54, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
