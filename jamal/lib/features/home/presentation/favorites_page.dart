import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/app_fonts.dart';
import '../../../core/app_localizations.dart';
import '../../../core/favorites_store.dart';
import '../data/salon_repository.dart';
import '../data/salon_store.dart';
import 'salon_detail_page.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({Key? key}) : super(key: key);

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
          t.translate('favorites_title'),
          style: AppFonts.plusJakartaSans(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: ValueListenableBuilder<List<Salon>>(
        valueListenable: SalonStore().remoteSalons,
        builder: (context, remoteSalons, child) {
          return ValueListenableBuilder<List<Salon>>(
            valueListenable: SalonStore().salons,
            builder: (context, customSalons, child) {
              return ValueListenableBuilder<Set<String>>(
                valueListenable: FavoritesStore().favorites,
                builder: (context, favorites, child) {
                  final allSalons = [...customSalons, ...remoteSalons];
                  final salons = allSalons.where((salon) => favorites.contains(salon.id)).toList();
                  if (salons.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.favorite_border_rounded, size: 64, color: colorScheme.onSurface.withOpacity(0.3)),
                          const SizedBox(height: 16),
                          Text(
                            t.translate('favorites_empty'),
                            style: AppFonts.plusJakartaSans(
                              color: colorScheme.onSurface.withOpacity(0.6),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    itemCount: salons.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final salon = salons[index];
                      return _FavoriteSalonTile(salon: salon);
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _FavoriteSalonTile extends StatelessWidget {
  final Salon salon;

  const _FavoriteSalonTile({Key? key, required this.salon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const primaryPink = Color(0xFFFF6F91);
    final t = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
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
              color: Colors.black.withOpacity(0.12),
              blurRadius: 14,
              offset: const Offset(0, 8),
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
                child: _buildSalonImage(salon.image, width: 108, height: 108),
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
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        t.translate(salon.address),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.plusJakartaSans(
                          color: Colors.black54,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            salon.rating.toString(),
                            style: AppFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 12, color: Colors.black87),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: InkResponse(
                  onTap: () => FavoritesStore().toggleFavorite(salon.id),
                  radius: 22,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: primaryPink.withOpacity(0.12),
                      shape: BoxShape.circle,
                      border: Border.all(color: primaryPink.withOpacity(0.3)),
                    ),
                    child: const Icon(Icons.favorite, color: primaryPink, size: 18),
                  ),
                ),
              ),
            ],
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
