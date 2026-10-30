import 'package:dartz/dartz.dart';
import 'package:iveco_find/src/core/services/dio_client.dart';
import 'package:iveco_find/src/shared/models/auth_model.dart';
import 'package:iveco_find/src/shared/utils/failure.dart';

class AuthRepository {
  final ClientDio dio;
  AuthRepository({required this.dio});

  Future<Either<Failure, AuthModel>> auth({
    required String email,
    required String password,
  }) async {
    try {
      final result = await dio.post(
        '/api/v1/auth/login',
        data: {"email": email, "senha": password},
      );

      if (result.statusCode != 200) {
        return Left(Failure(message: 'Falha ao realizar login.'));
      }
      return Right(AuthModel.fromJson(result.data));
    } catch (e) {
      return Left(Failure(message: 'Falha ao realizar login.'));
    }
  }

  Future<Either<Failure, bool>> logout() async {
    try {
      await dio.post('/api/v1/auth/logout', isAuth: true);
      return Right(true);
    } catch (e) {
      return Left(Failure(message: 'Falha ao realizar o logout.'));
    }
  }
}
