import 'dart:convert';
import 'package:http/http.dart' as http;
import 'salon_repository.dart';

abstract class SalonRemoteDataSource {
  Future<List<Salon>> fetchSalons();
  Future<Salon?> createSalon({
    required String name,
    required String description,
    String? imageUrl,
  });
  Future<void> createService({
    required String salonId,
    required String name,
    required String description,
    required String price,
    String imageUrl,
  });
  Future<void> createMaster({
    required String salonId,
    required String fullName,
    required String photoUrl,
  });
}

class HttpSalonRemoteDataSource implements SalonRemoteDataSource {
  HttpSalonRemoteDataSource({http.Client? client}) : _client = client ?? http.Client();

  static const String _url = 'https://dash.vips.uz/api/49/7299/103405';
  static const String _createUrl = 'https://dash.vips.uz/api-in/49/7299/103405';
  static const String _createServiceUrl = 'https://dash.vips.uz/api-in/49/7299/103406';
  static const String _createMasterUrl = 'https://dash.vips.uz/api-in/49/7299/103402';

  final http.Client _client;

  @override
  Future<List<Salon>> fetchSalons() async {
    final response = await _client.get(Uri.parse(_url));
    if (response.statusCode != 200) {
      return <Salon>[];
    }

    final decoded = jsonDecode(response.body);
    final rawList = decoded is Map<String, dynamic> ? decoded['value'] : decoded;
    if (rawList is! List) {
      return <Salon>[];
    }

    return rawList
        .whereType<Map>()
        .map((item) => _fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  @override
  Future<Salon?> createSalon({
    required String name,
    required String description,
    String? imageUrl,
  }) async {
    final body = jsonEncode({
      'name': name,
      'short_description': description,
      'rating': '0.0',
      'image': imageUrl ?? '',
    });

    final response = await _client.post(
      Uri.parse(_createUrl),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Server error: ${response.statusCode}: ${response.body}');
    }

    final decoded = jsonDecode(response.body);
    Map<String, dynamic>? data;
    if (decoded is List) {
      if (decoded.isNotEmpty && decoded.first is Map<String, dynamic>) {
        data = decoded.first as Map<String, dynamic>;
      }
    } else if (decoded is Map<String, dynamic>) {
      data = decoded;
    }
    if (data == null) {
      return null;
    }

    return _fromJson(data);
  }

  @override
  Future<void> createService({
    required String salonId,
    required String name,
    required String description,
    required String price,
    String imageUrl = '',
  }) async {
    final body = jsonEncode({
      'name': name,
      'description': description,
      'image': imageUrl,
      'price': price,
      'salon_id': salonId,
    });

    final response = await _client.post(
      Uri.parse(_createServiceUrl),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Server error: ${response.statusCode}: ${response.body}');
    }
  }

  @override
  Future<void> createMaster({
    required String salonId,
    required String fullName,
    required String photoUrl,
  }) async {
    final body = jsonEncode({
      'salon_id': salonId,
      'full_name': fullName,
      'photo': photoUrl,
    });

    final response = await _client.post(
      Uri.parse(_createMasterUrl),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Server error: ${response.statusCode}: ${response.body}');
    }
  }

  Salon _fromJson(Map<String, dynamic> json) {
    return Salon(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      address: json['short_description']?.toString() ?? '',
      rating: 0.0,
      image: json['image']?.toString() ?? 'assets/salon.png',
    );
  }
}
