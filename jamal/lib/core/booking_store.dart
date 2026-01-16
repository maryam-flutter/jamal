import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'booking_remote_data_source.dart';

class Booking {
  final String id;
  final String? userId;
  final String salonId;
  final String? serviceId;
  final String? masterId;
  final String salonName;
  final String salonImage;
  final String serviceTitle;
  final String? serviceTitleKey;
  final String priceLabel;
  final String? priceKey;
  final String dateLabel;
  final int? dateEpoch;
  final String timeLabel;
  final String? appointmentTime;
  final String status;
  final int createdAt;

  const Booking({
    required this.id,
    this.userId,
    required this.salonId,
    this.serviceId,
    this.masterId,
    required this.salonName,
    required this.salonImage,
    required this.serviceTitle,
    this.serviceTitleKey,
    required this.priceLabel,
    this.priceKey,
    required this.dateLabel,
    this.dateEpoch,
    required this.timeLabel,
    this.appointmentTime,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'salonId': salonId,
      'serviceId': serviceId,
      'masterId': masterId,
      'salonName': salonName,
      'salonImage': salonImage,
      'serviceTitle': serviceTitle,
      'serviceTitleKey': serviceTitleKey,
      'priceLabel': priceLabel,
      'priceKey': priceKey,
      'dateLabel': dateLabel,
      'dateEpoch': dateEpoch,
      'timeLabel': timeLabel,
      'appointmentTime': appointmentTime,
      'status': status,
      'createdAt': createdAt,
    };
  }

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      userId: json['userId'] as String?,
      salonId: json['salonId'] as String,
      serviceId: json['serviceId'] as String?,
      masterId: json['masterId'] as String?,
      salonName: json['salonName'] as String,
      salonImage: json['salonImage'] as String,
      serviceTitle: (json['serviceTitle'] as String?) ?? '',
      serviceTitleKey: json['serviceTitleKey'] as String?,
      priceLabel: (json['priceLabel'] as String?) ?? '',
      priceKey: json['priceKey'] as String?,
      dateLabel: (json['dateLabel'] as String?) ?? '',
      dateEpoch: json['dateEpoch'] as int?,
      timeLabel: (json['timeLabel'] as String?) ?? '',
      appointmentTime: json['appointmentTime'] as String?,
      status: (json['status'] as String?) ?? 'active',
      createdAt: (json['createdAt'] as int?) ?? 0,
    );
  }
}

class BookingStore {
  static final BookingStore _instance = BookingStore._internal();

  factory BookingStore() {
    return _instance;
  }

  BookingStore._internal();

  static const String _storageKey = 'bookings';

  final ValueNotifier<List<Booking>> bookings = ValueNotifier(<Booking>[]);
  final BookingRemoteDataSource _remoteDataSource = HttpBookingRemoteDataSource();

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      bookings.value = <Booking>[];
      return;
    }
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      bookings.value = <Booking>[];
      return;
    }
    final items = decoded
        .whereType<Map>()
        .map((e) => Booking.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    final migrated = await _enrichBookings(items);
    bookings.value = migrated;
  }

  Future<void> addBooking(Booking booking) async {
    final updated = <Booking>[booking, ...bookings.value];
    bookings.value = updated;
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(updated.map((b) => b.toJson()).toList());
    await prefs.setString(_storageKey, raw);
  }

  Future<void> createRemoteBooking({
    required String userId,
    required String salonId,
    required String serviceId,
    required String masterId,
    required String appointmentTime,
    required String status,
  }) async {
    await _remoteDataSource.createBooking(
      userId: userId,
      salonId: salonId,
      serviceId: serviceId,
      masterId: masterId,
      appointmentTime: appointmentTime,
      status: status,
    );
  }

  Future<List<Booking>> _enrichBookings(List<Booking> items) async {
    final maps = await _loadTranslationMaps();
    final reverseMap = maps.valueToKey;
    final monthMap = maps.monthValueToIndex;
    bool changed = false;
    final updated = items.map((booking) {
      final serviceKey = booking.serviceTitleKey ?? reverseMap[booking.serviceTitle];
      final priceKey = booking.priceKey ?? reverseMap[booking.priceLabel];
      final dateEpoch = booking.dateEpoch ?? _tryParseDateEpoch(booking.dateLabel, booking.createdAt, monthMap);
      if (serviceKey != booking.serviceTitleKey || priceKey != booking.priceKey || dateEpoch != booking.dateEpoch) {
        changed = true;
      }
      return Booking(
        id: booking.id,
        userId: booking.userId,
        salonId: booking.salonId,
        serviceId: booking.serviceId,
        masterId: booking.masterId,
        salonName: booking.salonName,
        salonImage: booking.salonImage,
        serviceTitle: booking.serviceTitle,
        serviceTitleKey: serviceKey,
        priceLabel: booking.priceLabel,
        priceKey: priceKey,
        dateLabel: booking.dateLabel,
        dateEpoch: dateEpoch,
        timeLabel: booking.timeLabel,
        appointmentTime: booking.appointmentTime,
        status: booking.status,
        createdAt: booking.createdAt,
      );
    }).toList();
    if (changed) {
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonEncode(updated.map((b) => b.toJson()).toList());
      await prefs.setString(_storageKey, raw);
    }
    return updated;
  }

  Future<_TranslationMaps> _loadTranslationMaps() async {
    final files = ['assets/langs/uz.json', 'assets/langs/ru.json', 'assets/langs/en.json', 'assets/langs/ar.json'];
    final valueToKey = <String, String>{};
    final monthValueToIndex = <String, int>{};
    for (final path in files) {
      try {
        final raw = await rootBundle.loadString(path);
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          decoded.forEach((key, value) {
            final val = value?.toString() ?? '';
            if (val.isEmpty) return;
            if (!valueToKey.containsKey(val)) {
              valueToKey[val] = key;
            }
            if (key.startsWith('month_') && !monthValueToIndex.containsKey(val)) {
              final monthIndex = _monthIndexFromKey(key);
              if (monthIndex != null) {
                monthValueToIndex[val] = monthIndex;
              }
            }
          });
        }
      } catch (_) {
        // Ignore missing/invalid translation files.
      }
    }
    return _TranslationMaps(valueToKey: valueToKey, monthValueToIndex: monthValueToIndex);
  }

  int? _monthIndexFromKey(String key) {
    const map = {
      'month_jan': 1,
      'month_feb': 2,
      'month_mar': 3,
      'month_apr': 4,
      'month_may': 5,
      'month_jun': 6,
      'month_jul': 7,
      'month_aug': 8,
      'month_sep': 9,
      'month_oct': 10,
      'month_nov': 11,
      'month_dec': 12,
    };
    return map[key];
  }

  int? _tryParseDateEpoch(String label, int createdAt, Map<String, int> monthMap) {
    if (label.isEmpty) return null;
    final parts = label.split(' ');
    if (parts.length < 2) return null;
    final day = int.tryParse(parts[0]);
    if (day == null) return null;
    final monthIndex = monthMap[parts[1]];
    if (monthIndex == null) return null;
    final created = createdAt > 0 ? DateTime.fromMillisecondsSinceEpoch(createdAt) : DateTime.now();
    final date = DateTime(created.year, monthIndex, day);
    return date.millisecondsSinceEpoch;
  }
}

class _TranslationMaps {
  final Map<String, String> valueToKey;
  final Map<String, int> monthValueToIndex;

  _TranslationMaps({required this.valueToKey, required this.monthValueToIndex});
}
