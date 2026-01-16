import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/app_fonts.dart';
import '../../../core/app_localizations.dart';
import '../../../core/favorites_store.dart';
import '../data/salon_repository.dart';
import '../data/salon_store.dart';
import 'salon_detail_page.dart';

class AllSalonsPage extends StatelessWidget {
  const AllSalonsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
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
          t.translate('home_salons_title'),
          style: AppFonts.plusJakartaSans(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: ValueListenableBuilder<List<Salon>>(
        valueListenable: SalonStore().remoteSalons,
        builder: (context, remoteSalons, child) {
          return ValueListenableBuilder<List<Salon>>(
            valueListenable: SalonStore().salons,
            builder: (context, customSalons, child) {
              final salons = [...customSalons, ...remoteSalons];
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                itemCount: salons.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final salon = salons[index];
                  return _SalonListTile(salon: salon);
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _SalonListTile extends StatelessWidget {
  final Salon salon;

  const _SalonListTile({Key? key, required this.salon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const primaryPink = Color(0xFFFF6F91);
    final t = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFF6F8), Color(0xFFFFE3EA), Color(0xFFFFFFFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => SalonDetailPage(salon: salon)));
            },
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    bottomLeft: Radius.circular(18),
                  ),
                  child: _buildSalonImage(salon.image, width: 110, height: 110),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.translate(salon.name),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        style: AppFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                        const SizedBox(height: 6),
                        Text(
                          t.translate(salon.address),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        style: AppFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              salon.rating.toString(),
                              style: AppFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black87),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ValueListenableBuilder<Set<String>>(
                    valueListenable: FavoritesStore().favorites,
                    builder: (context, favorites, child) {
                      final isFavorite = favorites.contains(salon.id);
                      return InkResponse(
                        onTap: () => FavoritesStore().toggleFavorite(salon.id),
                        radius: 22,
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? primaryPink : Colors.grey[600],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildSalonImage(String path, {double? width, double? height}) {
  if (path.startsWith('http://') || path.startsWith('https://')) {
    return Image.network(
      path,
      width: width,
      height: height,
      fit: BoxFit.cover,
      headers: const {'User-Agent': 'Mozilla/5.0'},
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(width: width, height: height, color: Colors.grey[300]);
      },
      errorBuilder: (_, __, ___) => Container(width: width, height: height, color: Colors.grey[300]),
    );
  }
  if (path.startsWith('assets/')) {
    return Image.asset(
      path,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(width: width, height: height, color: Colors.grey[300]),
    );
  }
  final file = File(path);
  if (file.existsSync()) {
    return Image.file(
      file,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(width: width, height: height, color: Colors.grey[300]),
    );
  }
  return Container(width: width, height: height, color: Colors.grey[300]);
}
