import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> register({required String ismi, required String tel, required String parol});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;
  AuthRemoteDataSourceImpl({required this.client});

  static const _url = 'https://dash.vips.uz/api/49/7299/103404';

  @override
  Future<UserModel> register({required String ismi, required String tel, required String parol}) async {
    final body = jsonEncode({
      'ismi': ismi,
      'telifonraqami': tel,
      'parol': parol,
    });

    final res = await client.post(
      Uri.parse(_url),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      final decoded = jsonDecode(res.body);

      // Handle if API returns a List or a Map
      Map<String, dynamic> data;
      if (decoded is List) {
        if (decoded.isEmpty) {
          throw Exception('Bo\'sh javob (empty list) from server: ${res.body}');
        }
        final first = decoded[0];
        if (first is Map<String, dynamic>) {
          data = first;
        } else {
          throw Exception('Unexpected list element type: ${first.runtimeType}. Response: ${res.body}');
        }
      } else if (decoded is Map<String, dynamic>) {
        data = decoded;
      } else {
        throw Exception('Unexpected JSON type: ${decoded.runtimeType}. Response: ${res.body}');
      }

      return UserModel.fromJson(data);
    } else {
      // Log response body for debugging
      throw Exception('Server error: ${res.statusCode}: ${res.body}');
    }
  }
}