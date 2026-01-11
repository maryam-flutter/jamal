import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;
  RegisterUseCase({required this.repository});

  Future<User> execute({required String ismi, required String tel, required String parol}) {
    return repository.register(ismi: ismi, tel: tel, parol: parol);
  }
}