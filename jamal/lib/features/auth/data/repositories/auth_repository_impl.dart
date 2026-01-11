import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  AuthRepositoryImpl({required this.remote});

  @override
  Future<User> register({required String ismi, required String tel, required String parol}) async {
    final UserModel model = await remote.register(ismi: ismi, tel: tel, parol: parol);
    return model;
  }
}