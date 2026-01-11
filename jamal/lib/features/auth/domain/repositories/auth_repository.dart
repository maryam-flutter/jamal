import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> register({required String ismi, required String tel, required String parol});
}