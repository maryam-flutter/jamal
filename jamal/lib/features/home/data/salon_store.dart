import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'salon_repository.dart';
import 'salon_remote_data_source.dart';

class SalonStore {
  static final SalonStore _instance = SalonStore._internal();

  factory SalonStore() {
    return _instance;
  }

  SalonStore._internal();

  static const String _storageKey = 'custom_salons';
  static const String _servicesStorageKey = 'custom_salon_services';
  static const String _mastersStorageKey = 'custom_salon_masters';
  static const String _remoteSalonsStorageKey = 'remote_salons';

  final ValueNotifier<List<Salon>> salons = ValueNotifier(<Salon>[]);
  final ValueNotifier<List<SalonService>> services = ValueNotifier(<SalonService>[]);
  final ValueNotifier<List<SalonMaster>> masters = ValueNotifier(<SalonMaster>[]);
  final ValueNotifier<List<Salon>> remoteSalons = ValueNotifier(<Salon>[]);

  final SalonRemoteDataSource _remoteDataSource = HttpSalonRemoteDataSource();

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final rawSalons = prefs.getString(_storageKey);
    if (rawSalons == null || rawSalons.isEmpty) {
      salons.value = <Salon>[];
    } else {
      final decoded = jsonDecode(rawSalons);
      if (decoded is! List) {
        salons.value = <Salon>[];
      } else {
        final items = decoded
            .whereType<Map>()
            .map((e) => _fromJson(Map<String, dynamic>.from(e)))
            .toList();
        salons.value = items;
      }
    }

    final rawServices = prefs.getString(_servicesStorageKey);
    if (rawServices == null || rawServices.isEmpty) {
      services.value = <SalonService>[];
    } else {
      final decodedServices = jsonDecode(rawServices);
      if (decodedServices is! List) {
        services.value = <SalonService>[];
      } else {
        final items = decodedServices
            .whereType<Map>()
            .map((e) => _serviceFromJson(Map<String, dynamic>.from(e)))
            .toList();
        services.value = items;
      }
    }

    final rawMasters = prefs.getString(_mastersStorageKey);
    if (rawMasters == null || rawMasters.isEmpty) {
      masters.value = <SalonMaster>[];
    } else {
      final decodedMasters = jsonDecode(rawMasters);
      if (decodedMasters is! List) {
        masters.value = <SalonMaster>[];
      } else {
        final items = decodedMasters
            .whereType<Map>()
            .map((e) => _masterFromJson(Map<String, dynamic>.from(e)))
            .toList();
        masters.value = items;
      }
    }

    final rawRemoteSalons = prefs.getString(_remoteSalonsStorageKey);
    if (rawRemoteSalons == null || rawRemoteSalons.isEmpty) {
      remoteSalons.value = <Salon>[];
    } else {
      final decodedRemote = jsonDecode(rawRemoteSalons);
      if (decodedRemote is! List) {
        remoteSalons.value = <Salon>[];
      } else {
        final items = decodedRemote
            .whereType<Map>()
            .map((e) => _fromJson(Map<String, dynamic>.from(e)))
            .toList();
        remoteSalons.value = items;
      }
    }

    loadRemoteSalons();
  }

  Future<void> loadRemoteSalons() async {
    try {
      final items = await _remoteDataSource.fetchSalons();
      remoteSalons.value = items;
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonEncode(items.map(_toJson).toList());
      await prefs.setString(_remoteSalonsStorageKey, raw);
    } catch (_) {
      remoteSalons.value = <Salon>[];
    }
  }

  Future<Salon?> createRemoteSalon({
    required String name,
    required String description,
    String? imageUrl,
  }) async {
    final created = await _remoteDataSource.createSalon(
      name: name,
      description: description,
      imageUrl: imageUrl,
    );
    if (created == null) return null;
    final updated = <Salon>[created, ...remoteSalons.value];
    remoteSalons.value = updated;
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(updated.map(_toJson).toList());
    await prefs.setString(_remoteSalonsStorageKey, raw);
    return created;
  }

  Future<void> createRemoteService({
    required String salonId,
    required String name,
    required String description,
    required String price,
    String imageUrl = '',
  }) async {
    await _remoteDataSource.createService(
      salonId: salonId,
      name: name,
      description: description,
      price: price,
      imageUrl: imageUrl,
    );
  }

  Future<void> createRemoteMaster({
    required String salonId,
    required String fullName,
    required String photoUrl,
  }) async {
    await _remoteDataSource.createMaster(
      salonId: salonId,
      fullName: fullName,
      photoUrl: photoUrl,
    );
  }

  Future<void> addSalon(
    Salon salon, {
    List<SalonService> salonServices = const [],
    List<SalonMaster> salonMasters = const [],
  }) async {
    final updated = <Salon>[salon, ...salons.value];
    salons.value = updated;
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(updated.map(_toJson).toList());
    await prefs.setString(_storageKey, raw);

    if (salonServices.isNotEmpty) {
      final updatedServices = <SalonService>[...salonServices, ...services.value];
      services.value = updatedServices;
      final rawServices = jsonEncode(updatedServices.map(_serviceToJson).toList());
      await prefs.setString(_servicesStorageKey, rawServices);
    }

    if (salonMasters.isNotEmpty) {
      final updatedMasters = <SalonMaster>[...salonMasters, ...masters.value];
      masters.value = updatedMasters;
      final rawMasters = jsonEncode(updatedMasters.map(_masterToJson).toList());
      await prefs.setString(_mastersStorageKey, rawMasters);
    }
  }

  Future<void> addSalonExtras({
    List<SalonService> salonServices = const [],
    List<SalonMaster> salonMasters = const [],
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (salonServices.isNotEmpty) {
      final updatedServices = <SalonService>[...salonServices, ...services.value];
      services.value = updatedServices;
      final rawServices = jsonEncode(updatedServices.map(_serviceToJson).toList());
      await prefs.setString(_servicesStorageKey, rawServices);
    }
    if (salonMasters.isNotEmpty) {
      final updatedMasters = <SalonMaster>[...salonMasters, ...masters.value];
      masters.value = updatedMasters;
      final rawMasters = jsonEncode(updatedMasters.map(_masterToJson).toList());
      await prefs.setString(_mastersStorageKey, rawMasters);
    }
  }

  Map<String, dynamic> _toJson(Salon salon) {
    return {
      'id': salon.id,
      'name': salon.name,
      'address': salon.address,
      'rating': salon.rating,
      'image': salon.image,
    };
  }

  Salon _fromJson(Map<String, dynamic> json) {
    return Salon(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      rating: 0.0,
      image: json['image'] as String? ?? 'assets/salon.png',
    );
  }

  Map<String, dynamic> _serviceToJson(SalonService service) {
    return {
      'id': service.id,
      'salonId': service.salonId,
      'titleKey': service.titleKey,
      'durationKey': service.durationKey,
      'priceKey': service.priceKey,
      'categoryKey': service.categoryKey,
    };
  }

  SalonService _serviceFromJson(Map<String, dynamic> json) {
    return SalonService(
      id: json['id'] as String? ?? '',
      salonId: json['salonId'] as String? ?? '',
      titleKey: json['titleKey'] as String? ?? '',
      durationKey: json['durationKey'] as String? ?? '',
      priceKey: json['priceKey'] as String? ?? '',
      categoryKey: json['categoryKey'] as String? ?? 'category_hair',
    );
  }

  List<SalonService> getServicesBySalon(String salonId) {
    return services.value.where((service) => service.salonId == salonId).toList();
  }

  Map<String, dynamic> _masterToJson(SalonMaster master) {
    return {
      'id': master.id,
      'salonId': master.salonId,
      'name': master.name,
      'image': master.image,
    };
  }

  SalonMaster _masterFromJson(Map<String, dynamic> json) {
    return SalonMaster(
      id: json['id'] as String? ?? '',
      salonId: json['salonId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      image: json['image'] as String? ?? 'assets/images/profile.png',
    );
  }

  List<SalonMaster> getMastersBySalon(String salonId) {
    return masters.value.where((master) => master.salonId == salonId).toList();
  }
}
