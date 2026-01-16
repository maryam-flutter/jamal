import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/app_fonts.dart';
import '../../../core/app_localizations.dart';
import '../../../core/app_snackbar.dart';
import '../../../core/booking_store.dart';
import '../../../core/favorites_store.dart';
import '../../../core/user_session.dart';
import '../data/salon_repository.dart';
import '../data/salon_store.dart';

class SalonDetailPage extends StatefulWidget {
  final Salon salon;

  const SalonDetailPage({Key? key, required this.salon}) : super(key: key);

  @override
  State<SalonDetailPage> createState() => _SalonDetailPageState();
}

class _SalonDetailPageState extends State<SalonDetailPage> {
  SalonService? _selectedService;

  @override
  Widget build(BuildContext context) {
    const primaryPink = Color(0xFFFF6F91);
    final t = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // 1. Orqa fon rasmi (Katta)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 320,
            child: _buildSalonImage(widget.salon.image),
          ),

          // 3. Asosiy ma'lumotlar (Pastdan chiqib turadigan oq quti)
          Positioned.fill(
            top: 260,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Salon nomi va Reyting
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t.translate(widget.salon.name),
                                style: AppFonts.plusJakartaSans(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      t.translate(widget.salon.address),
                                      style: AppFonts.plusJakartaSans(
                                        color: colorScheme.onSurface.withOpacity(0.6),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                              const SizedBox(width: 4),
                              Text(
                                widget.salon.rating.toString(),
                                style: AppFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.amber[800],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Ustalar (Masters)
                    Text(
                      t.translate('salon_masters_title'),
                      style: AppFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700, color: colorScheme.onSurface),
                    ),
                    const SizedBox(height: 16),
                    ValueListenableBuilder<List<SalonMaster>>(
                      valueListenable: SalonStore().masters,
                      builder: (context, customMasters, child) {
                        final masters = customMasters.where((master) => master.salonId == widget.salon.id).toList();
                        if (masters.isEmpty) {
                          return Text(
                            t.translate('no_services_yet'),
                            style: AppFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                          );
                        }
                        return SizedBox(
                          height: 90,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: masters.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 16),
                            itemBuilder: (context, index) {
                              final master = masters[index];
                              return Column(
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.grey[200],
                                    backgroundImage: _masterImageProvider(master.image),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    t.translate(master.name),
                                    style: AppFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Xizmatlar ro'yxati
                    Text(
                      t.translate('salon_services_title'),
                      style: AppFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700, color: colorScheme.onSurface),
                    ),
                    const SizedBox(height: 16),
                    ValueListenableBuilder<List<SalonService>>(
                      valueListenable: SalonStore().services,
                      builder: (context, customServices, child) {
                        final services = [
                          ...customServices.where((service) => service.salonId == widget.salon.id),
                          ...SalonRepository.getServicesBySalon(widget.salon.id),
                        ];
                        if (services.isEmpty) {
                          return Text(
                            t.translate('no_services_yet'),
                            style: AppFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                          );
                        }
                        return Column(
                          children: services.map((service) {
                            final isSelected = _selectedService?.id == service.id;
                            return _buildServiceItem(
                              t.translate(service.titleKey),
                              t.translate(service.durationKey),
                              t.translate(service.priceKey),
                              primaryPink,
                              t,
                              isSelected: isSelected,
                              onTap: () {
                                setState(() => _selectedService = service);
                                _openBookingSheet(context, service, t);
                              },
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 4. Pastki "Band qilish" tugmasi
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
              ),
              child: ElevatedButton(
                onPressed: () {
                  if (_selectedService == null) {
                    AppSnackBar.show(context, t.translate('booking_select_service_prompt'));
                    return;
                  }
                  _openBookingSheet(context, _selectedService!, t);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(
                  t.translate('salon_book_button'),
                  style: AppFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ),
            ),
          ),

          // 2. Orqaga qaytish va Sevimlilar tugmalari (Yuqorida turishi uchun oxiriga o'tkazildi)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCircleBtn(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () => Navigator.pop(context),
                    ),
                    ValueListenableBuilder<Set<String>>(
                      valueListenable: FavoritesStore().favorites,
                      builder: (context, favorites, child) {
                        final isFavorite = favorites.contains(widget.salon.id);
                        return _buildCircleBtn(
                          icon: isFavorite ? Icons.favorite : Icons.favorite_border_rounded,
                          onTap: () => FavoritesStore().toggleFavorite(widget.salon.id),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openBookingSheet(BuildContext context, SalonService service, AppLocalizations t) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BookingBottomSheet(
        salonId: widget.salon.id,
        salonName: widget.salon.name,
        salonImage: widget.salon.image,
        serviceId: service.id,
        serviceTitle: t.translate(service.titleKey),
        serviceTitleKey: service.titleKey,
        priceLabel: t.translate(service.priceKey),
        priceKey: service.priceKey,
      ),
    );
  }

  Widget _buildCircleBtn({required IconData icon, required VoidCallback onTap}) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: colorScheme.surface.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Icon(icon, color: colorScheme.onSurface, size: 22),
      ),
    );
  }

  Widget _buildServiceItem(
    String title,
    String duration,
    String price,
    Color color,
    AppLocalizations t, {
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFF7FA), Color(0xFFFFE1EA), Color(0xFFFFFFFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSelected ? color.withOpacity(0.2) : color.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isSelected ? Icons.check_rounded : Icons.spa_rounded,
                      color: color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: AppFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 15, color: Colors.black87)),
                        const SizedBox(height: 4),
                        Text(duration, style: AppFonts.plusJakartaSans(color: Colors.black54, fontSize: 12)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        price,
                        style: AppFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: Colors.black87, fontSize: 15),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSelected ? color : Colors.black,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isSelected ? t.translate('salon_selected') : t.translate('salon_select'),
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BookingBottomSheet extends StatefulWidget {
  final String salonId;
  final String salonName;
  final String salonImage;
  final String serviceId;
  final String serviceTitle;
  final String serviceTitleKey;
  final String priceLabel;
  final String priceKey;

  const _BookingBottomSheet({
    Key? key,
    required this.salonId,
    required this.salonName,
    required this.salonImage,
    required this.serviceId,
    required this.serviceTitle,
    required this.serviceTitleKey,
    required this.priceLabel,
    required this.priceKey,
  }) : super(key: key);

  @override
  State<_BookingBottomSheet> createState() => _BookingBottomSheetState();
}

class _BookingBottomSheetState extends State<_BookingBottomSheet> {
  int _selectedDayIndex = 0;
  int _selectedTimeIndex = -1;

  late List<String> _days;
  late List<String> _dates;
  late List<DateTime> _dateValues;
  String? _localeCode;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final t = AppLocalizations.of(context)!;
    final localeCode = Localizations.localeOf(context).languageCode;
    if (_localeCode == localeCode) return;
    _localeCode = localeCode;

    _days = [];
    _dates = [];
    _dateValues = [];
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, now.day);
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
    final weekDays = [
      '',
      t.translate('weekday_mon'),
      t.translate('weekday_tue'),
      t.translate('weekday_wed'),
      t.translate('weekday_thu'),
      t.translate('weekday_fri'),
      t.translate('weekday_sat'),
      t.translate('weekday_sun'),
    ];

    for (int i = 0; i < 60; i++) {
      final d = startDate.add(Duration(days: i));
      if (i == 0) {
        _days.add(t.translate('booking_today'));
      } else if (i == 1) {
        _days.add(t.translate('booking_tomorrow'));
      } else {
        _days.add(weekDays[d.weekday]);
      }
      _dates.add('${d.day} ${months[d.month]}');
      _dateValues.add(d);
    }

    if (_selectedDayIndex >= _days.length) {
      _selectedDayIndex = 0;
    }
  }

  final List<String> _timeSlots = [
    '10:00', '10:30', '11:00', '11:30',
    '14:00', '14:30', '15:00', '15:30',
    '16:00', '16:30', '17:00', '17:30',
  ];

  @override
  Widget build(BuildContext context) {
    const primaryPink = Color(0xFFFF6F91);
    final t = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surface : const Color.fromARGB(255, 255, 255, 255),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : const Color(0xFFDDDDDD),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
                Text(
                  t.translate('booking_select_date_time'),
                  style: AppFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: isDark ? const Color.fromRGBO(255, 255, 255, 1) : Colors.black,
                  ),
                ),
              if (_dates.isNotEmpty)
                Text(_dates[_selectedDayIndex].split(' ')[1], style: AppFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600, color: primaryPink)),
            ],
          ),
          const SizedBox(height: 8),
            Text(
              widget.serviceTitle,
              style: AppFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          const SizedBox(height: 24),
          // Date selector
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _days.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final isSelected = _selectedDayIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedDayIndex = index),
                  child: Container(
                    width: 64,
                      decoration: BoxDecoration(
                        color: isSelected ? primaryPink : (isDark ? const Color(0xFF2E2E2E) : const Color(0xFFF5F5F5)),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? primaryPink : (isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE2E2E2)),
                        ),
                      ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                          Text(
                            _days[index],
                            style: AppFonts.plusJakartaSans(
                              fontSize: 12,
                              color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.grey[600]),
                            ),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          _dates[index],
                            style: AppFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
            Text(
              t.translate('booking_available_times'),
              style: AppFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 2.2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _timeSlots.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedTimeIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedTimeIndex = index),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? primaryPink
                            : (isDark ? const Color(0xFF2E2E2E) : Colors.white),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? primaryPink : (isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE2E2E2)),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _timeSlots[index],
                        style: TextStyle(
                          color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: _SliderButton(
              enabled: _selectedTimeIndex != -1,
              onSlideComplete: () async {
                final selectedTime = _timeSlots[_selectedTimeIndex];
                final dateLabel = _dates[_selectedDayIndex];
                final dateEpoch = _dateValues[_selectedDayIndex].millisecondsSinceEpoch;
                final appointmentTime = '$dateLabel $selectedTime';
                final booking = Booking(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  userId: UserSession().userId,
                  salonId: widget.salonId,
                  serviceId: widget.serviceId,
                  masterId: '',
                  salonName: widget.salonName,
                  salonImage: widget.salonImage,
                  serviceTitle: widget.serviceTitle,
                  serviceTitleKey: widget.serviceTitleKey,
                  priceLabel: widget.priceLabel,
                  priceKey: widget.priceKey,
                  dateLabel: dateLabel,
                  dateEpoch: dateEpoch,
                  timeLabel: selectedTime,
                  appointmentTime: appointmentTime,
                  status: 'active',
                  createdAt: DateTime.now().millisecondsSinceEpoch,
                );
                try {
                  await BookingStore().createRemoteBooking(
                    userId: UserSession().userId ?? '',
                    salonId: widget.salonId,
                    serviceId: widget.serviceId,
                    masterId: '',
                    appointmentTime: appointmentTime,
                    status: 'active',
                  );
                } catch (_) {
                  // Best-effort remote sync.
                }
                await BookingStore().addBooking(booking);
                if (!mounted) return;
                Navigator.pop(context);
                AppSnackBar.show(context, t.translate('booking_snackbar'), style: AppSnackBarStyle.success);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SliderButton extends StatefulWidget {
  final VoidCallback onSlideComplete;
  final bool enabled;

  const _SliderButton({Key? key, required this.onSlideComplete, this.enabled = true}) : super(key: key);

  @override
  State<_SliderButton> createState() => _SliderButtonState();
}

class _SliderButtonState extends State<_SliderButton> {
  double _dragValue = 0.0;

  @override
  Widget build(BuildContext context) {
    const primaryPink = Color(0xFFFF6F91);
    final t = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth - 54;
        return Container(
          height: 54,
          decoration: BoxDecoration(
            color: widget.enabled
                ? (isDark ? const Color(0xFF2E2E2E) : const Color(0xFFFFF0F3))
                : (isDark ? const Color(0xFF3A3A3A) : Colors.grey[100]),
            borderRadius: BorderRadius.circular(27),
          ),
          child: Stack(
            children: [
              Center(
                child: Opacity(
                  opacity: 1.0 - (_dragValue / maxWidth).clamp(0.0, 1.0),
                  child: Text(
                    widget.enabled ? t.translate('booking_slide_to_confirm') : t.translate('booking_select_time_prompt'),
                    style: AppFonts.plusJakartaSans(
                      color: widget.enabled ? primaryPink : (isDark ? Colors.white38 : Colors.grey[400]),
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: _dragValue,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    if (!widget.enabled) return;
                    setState(() {
                      _dragValue = (_dragValue + details.delta.dx).clamp(0.0, maxWidth);
                    });
                  },
                  onHorizontalDragEnd: (details) {
                    if (!widget.enabled) return;
                    if (_dragValue > maxWidth * 0.7) {
                      setState(() => _dragValue = maxWidth);
                      widget.onSlideComplete();
                    } else {
                      setState(() {
                        _dragValue = 0.0;
                      });
                    }
                  },
                  child: Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: widget.enabled ? primaryPink : (isDark ? Colors.grey[700] : Colors.grey[300]),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (widget.enabled ? primaryPink : Colors.grey).withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
      errorBuilder: (_, __, ___) => Container(color: Colors.grey[300]),
    );
  }
  if (path.startsWith('assets/')) {
    return Image.asset(
      path,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(color: Colors.grey[300]),
    );
  }
  final file = File(path);
  if (file.existsSync()) {
    return Image.file(
      file,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(color: Colors.grey[300]),
    );
  }
  return Container(color: Colors.grey[300]);
}

ImageProvider _masterImageProvider(String path) {
  if (path.isEmpty) {
    return const AssetImage('assets/images/profile.png');
  }
  if (path.startsWith('assets/')) {
    return AssetImage(path);
  }
  final file = File(path);
  if (file.existsSync()) {
    return FileImage(file);
  }
  return const AssetImage('assets/images/profile.png');
}
