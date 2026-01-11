import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SalonDetailPage extends StatelessWidget {
  final Map<String, dynamic> salon;

  const SalonDetailPage({Key? key, required this.salon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const primaryPink = Color(0xFFFF6F91);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Orqa fon rasmi (Katta)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 320,
            child: Image.asset(
              salon['image'],
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: Colors.grey[300]),
            ),
          ),
          
          // 3. Asosiy ma'lumotlar (Pastdan chiqib turadigan oq quti)
          Positioned.fill(
            top: 260,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
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
                                salon['name'] ?? 'Salon Nomi',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      salon['address'] ?? 'Manzil',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: Colors.grey[600],
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
                                '${salon['rating']}',
                                style: GoogleFonts.plusJakartaSans(
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
                      'Bizning ustalarimiz',
                      style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 90,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: 6,
                        separatorBuilder: (_, __) => const SizedBox(width: 16),
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: primaryPink.withOpacity(0.5), width: 2),
                                ),
                                child: CircleAvatar(
                                  radius: 28,
                                  backgroundColor: Colors.grey[200],
                                  backgroundImage: const AssetImage('assets/images/profile.png'),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Usta ${index + 1}',
                                style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Xizmatlar ro'yxati
                    Text(
                      'Xizmatlar',
                      style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 16),
                    _buildServiceItem('Soch qirqish va turmaklash', '45 daqiqa', '150.000 so\'m', primaryPink),
                    _buildServiceItem('Manikyur (Shellac)', '90 daqiqa', '120.000 so\'m', primaryPink),
                    _buildServiceItem('Yuz tozalash (Piling)', '60 daqiqa', '200.000 so\'m', primaryPink),
                    _buildServiceItem('Kelinlar makiyaji', '120 daqiqa', '500.000 so\'m', primaryPink),
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
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
              ),
              child: ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const _BookingBottomSheet(),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(
                  'Vaqtni band qilish',
                  style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
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
                      icon: Icons.arrow_back_rounded,
                      onTap: () => Navigator.pop(context),
                    ),
                    _buildCircleBtn(
                      icon: Icons.favorite_border_rounded,
                      onTap: () {},
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

  Widget _buildCircleBtn({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Icon(icon, color: Colors.black87, size: 22),
      ),
    );
  }

  Widget _buildServiceItem(String title, String duration, String price, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.spa_rounded, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 4),
                Text(duration, style: GoogleFonts.plusJakartaSans(color: Colors.grey[500], fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(price, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: Colors.black, fontSize: 15)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(8)),
                child: const Text('Tanlash', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BookingBottomSheet extends StatefulWidget {
  const _BookingBottomSheet({Key? key}) : super(key: key);

  @override
  State<_BookingBottomSheet> createState() => _BookingBottomSheetState();
}

class _BookingBottomSheetState extends State<_BookingBottomSheet> {
  int _selectedDayIndex = 0;
  int _selectedTimeIndex = -1;

  late final List<String> _days;
  late final List<String> _dates;

  @override
  void initState() {
    super.initState();
    _days = [];
    _dates = [];
    final now = DateTime.now();
    const months = ['', 'Yan', 'Fev', 'Mar', 'Apr', 'May', 'Iyun', 'Iyul', 'Avg', 'Sen', 'Okt', 'Noy', 'Dek'];
    const weekDays = ['', 'Dush', 'Sesh', 'Chor', 'Pay', 'Juma', 'Shan', 'Yak'];

    for (int i = 0; i < 60; i++) {
      final d = now.add(Duration(days: i));
      if (i == 0) _days.add('Bugun');
      else if (i == 1) _days.add('Ertaga');
      else _days.add(weekDays[d.weekday]);
      _dates.add('${d.day} ${months[d.month]}');
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

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Sana va vaqtni tanlang', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800)),
              if (_dates.isNotEmpty)
                Text(_dates[_selectedDayIndex].split(' ')[1], style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600, color: primaryPink)),
            ],
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
                      color: isSelected ? primaryPink : Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isSelected ? primaryPink : Colors.grey[200]!),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_days[index], style: GoogleFonts.plusJakartaSans(fontSize: 12, color: isSelected ? Colors.white : Colors.grey[500])),
                        const SizedBox(height: 4),
                        Text(_dates[index], style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: isSelected ? Colors.white : Colors.black)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          Text('Mavjud vaqtlar', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700)),
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
                      color: isSelected ? Colors.black : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isSelected ? Colors.black : Colors.grey[300]!),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _timeSlots[index],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
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
              onSlideComplete: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vaqt tanlandi, to'lov sahifasiga o'tilmoqda...")));
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth - 54;
        return Container(
          height: 54,
          decoration: BoxDecoration(
            color: widget.enabled ? const Color(0xFFFFF0F3) : Colors.grey[100],
            borderRadius: BorderRadius.circular(27),
          ),
          child: Stack(
            children: [
              Center(
                child: Opacity(
                  opacity: 1.0 - (_dragValue / maxWidth).clamp(0.0, 1.0),
                  child: Text(
                    widget.enabled ? "Tasdiqlash uchun suring" : "Vaqtni tanlang",
                    style: GoogleFonts.plusJakartaSans(
                      color: widget.enabled ? primaryPink : Colors.grey[400],
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
                      color: widget.enabled ? primaryPink : Colors.grey[300],
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