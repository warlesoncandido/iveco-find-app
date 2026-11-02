import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
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

  /// Troca a própria senha (inclusive a Senha Provisória). A sessão atual continua válida.
  Future<Either<Failure, bool>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await dio.post(
        '/api/v1/auth/senha',
        isAuth: true,
        data: {'senhaAtual': currentPassword, 'novaSenha': newPassword},
      );
      return Right(true);
    } catch (e) {
      String? message;
      String? code;
      if (e is DioException && e.response?.data is Map) {
        message = e.response!.data['detail'] as String?;
        code = e.response!.data['codigo'] as String?;
      }
      return Left(
        Failure(message: message ?? 'Falha ao trocar a senha.', code: code),
      );
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
