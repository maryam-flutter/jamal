import 'dart:convert';
import '../../domain/entities/user.dart';

class UserModel extends User {
  UserModel({required String id, required String ismi, required String telifonraqami})
      : super(id: id, ismi: ismi, telifonraqami: telifonraqami);

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      ismi: json['ismi'] ?? json['name'] ?? '',
      telifonraqami: json['telifonraqami'] ?? json['phone'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ismi': ismi,
      'telifonraqami': telifonraqami,
    };
  }

  @override
  String toString() => jsonEncode(toJson());
}