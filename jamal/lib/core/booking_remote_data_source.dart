import 'dart:convert';
import 'package:http/http.dart' as http;

abstract class BookingRemoteDataSource {
  Future<void> createBooking({
    required String userId,
    required String salonId,
    required String serviceId,
    required String masterId,
    required String appointmentTime,
    required String status,
  });
}

class HttpBookingRemoteDataSource implements BookingRemoteDataSource {
  HttpBookingRemoteDataSource({http.Client? client}) : _client = client ?? http.Client();

  static const String _url = 'https://dash.vips.uz/api-in/49/7299/103401';

  final http.Client _client;

  @override
  Future<void> createBooking({
    required String userId,
    required String salonId,
    required String serviceId,
    required String masterId,
    required String appointmentTime,
    required String status,
  }) async {
    final body = jsonEncode({
      'users_id': userId,
      'salons_id': salonId,
      'sevices_id': serviceId,
      'masters_id': masterId,
      'appointment_time': appointmentTime,
      'status': status,
    });

    final response = await _client.post(
      Uri.parse(_url),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Server error: ${response.statusCode}: ${response.body}');
    }
  }
}
