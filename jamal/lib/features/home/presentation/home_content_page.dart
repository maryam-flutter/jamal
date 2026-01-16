import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/app_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/app_localizations.dart';
import '../../../core/favorites_store.dart';
import '../../../core/user_session.dart';
import '../data/salon_repository.dart';
import '../data/salon_store.dart';
import 'all_salons_page.dart';
import 'salon_detail_page.dart';

const Color _primaryPink = Color(0xFFFF6F91);

class HomeContentPage extends StatefulWidget {
  const HomeContentPage({Key? key}) : super(key: key);

  @override
  State<HomeContentPage> createState() => _HomeContentPageState();
}

class _HomeContentPageState extends State<HomeContentPage> {
  int _currentPage = 0;
  late PageController _pageController;
  Timer? _timer;
  File? _profileImage;

  final List<String> _sliderImages = [
    'assets/beauty.png',
    'assets/qween.png',
    'assets/ooo.png',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
    _loadProfileImage();
    // Change slide every 3 seconds
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      _currentPage++;

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.fastOutSlowIn,
        );
      }
    });
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

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final userName = UserSession().userName ?? t.translate('user_default');

    return SafeArea(
      child: Column(
        children: [
          // Top black header with app name, user name and avatar
          ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFF6F8), Color(0xFFFFC8D3), Color(0xFFFFFFFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _primaryPink.withOpacity(0.25),
                      blurRadius: 22,
                      offset: const Offset(0, 12),
                    ),
                  ],
                  border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.5), width: 1)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${t.translate('home_greeting')}, $userName!',
                            style: AppFonts.plusJakartaSans(
                              textStyle: const TextStyle(
                                color: Colors.black87,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            t.translate('home_take_time'),
                            style: AppFonts.plusJakartaSans(
                              textStyle: TextStyle(color: Colors.black.withOpacity(0.55), fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.7), width: 2),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 12, spreadRadius: 1),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.white,
                        child: ClipOval(
                          child: _profileImage != null
                              ? Image.file(_profileImage!, width: 52, height: 52, fit: BoxFit.cover)
                              : Image.asset(
                                  'assets/images/profile.png',
                                  width: 52,
                                  height: 52,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 28, color: Colors.white),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),

          // Content area with a card showing salons list
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Slider section
                SizedBox(
                  height: 170,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemBuilder: (context, index) {
                      final i = index % 3;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: DecorationImage(
                            image: AssetImage(_sliderImages[i]),
                            fit: BoxFit.cover,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 16,
                              left: 16,
                              right: 16,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _primaryPink,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${t.translate('home_discount')} -${(i + 1) * 10}%',
                                      style: AppFonts.plusJakartaSans(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    i == 0
                                        ? t.translate('home_promo_summer')
                                        : (i == 1 ? t.translate('home_promo_bride') : t.translate('home_promo_weekend')),
                                    style: AppFonts.plusJakartaSans(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                // Heart indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        Icons.favorite,
                        size: _currentPage % 3 == index ? 14 : 8,
                        color: _currentPage % 3 == index ? _primaryPink : Colors.grey[300],
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _SectionHeader(
                    title: t.translate('home_salons_title'),
                    seeAllLabel: t.translate('home_see_all'),
                    onSeeAll: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AllSalonsPage()));
                    },
                  ),
                ),
                const SizedBox(height: 8),
                // Grid view of salons
                Expanded(
                  child: ValueListenableBuilder<List<Salon>>(
                    valueListenable: SalonStore().remoteSalons,
                    builder: (context, remoteSalons, child) {
                      return ValueListenableBuilder<List<Salon>>(
                        valueListenable: SalonStore().salons,
                        builder: (context, customSalons, child) {
                          final salons = [...customSalons, ...remoteSalons];
                          return GridView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.78,
                            ),
                            itemCount: salons.length,
                            itemBuilder: (context, index) {
                              final s = salons[index];
                              return _SalonCard(salon: s);
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String seeAllLabel;
  final VoidCallback onSeeAll;

  const _SectionHeader({Key? key, required this.title, required this.seeAllLabel, required this.onSeeAll}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppFonts.plusJakartaSans(
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black),
          ),
        ),
        InkWell(
          onTap: onSeeAll,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Text(
                  seeAllLabel,
                  style: AppFonts.plusJakartaSans(
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _primaryPink,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_rounded, size: 16, color: _primaryPink),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SalonCard extends StatelessWidget {
  final Salon salon;

  const _SalonCard({Key? key, required this.salon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final name = t.translate(salon.name);
    // Simulation of a longer name for visual variety
    final title = name.length > 15 ? '$name - ${t.translate('home_professional_services')}' : name;

    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => SalonDetailPage(salon: salon)));
      },
      borderRadius: BorderRadius.circular(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Positioned.fill(
              child: _buildSalonImage(salon.image),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.45), Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.center,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    const SizedBox(width: 6),
                    Text(salon.rating.toString(),
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(color: Colors.white70, shape: BoxShape.circle),
                child: ValueListenableBuilder<Set<String>>(
                  valueListenable: FavoritesStore().favorites,
                  builder: (context, favorites, child) {
                    final isFavorite = favorites.contains(salon.id);
                    return InkWell(
                      onTap: () => FavoritesStore().toggleFavorite(salon.id),
                      borderRadius: BorderRadius.circular(20),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 18,
                        color: isFavorite ? _primaryPink : Colors.black54,
                      ),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              left: 10,
              right: 56,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.plusJakartaSans(
                      textStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '\$${(salon.rating * 1.2).toStringAsFixed(2)}',
                    style: AppFonts.plusJakartaSans(
                        textStyle: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 10,
              right: 10,
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_forward_rounded, color: _primaryPink, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildSalonImage(String path) {
  if (path.startsWith('http://') || path.startsWith('https://')) {
    return Image.network(
      path,
      fit: BoxFit.cover,
      headers: const {'User-Agent': 'Mozilla/5.0'},
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(color: Colors.grey[300]);
      },
      errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[300]),
    );
  }
  if (path.startsWith('assets/')) {
    return Image.asset(
      path,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[300]),
    );
  }
  final file = File(path);
  if (file.existsSync()) {
    return Image.file(
      file,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[300]),
    );
  }
  return Container(color: Colors.grey[300]);
}
