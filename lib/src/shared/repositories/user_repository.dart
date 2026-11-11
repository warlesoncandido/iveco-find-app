import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:iveco_find/src/core/services/dio_client.dart';
import 'package:iveco_find/src/shared/models/pagination_model.dart';
import 'package:iveco_find/src/shared/models/provisional_password_model.dart';
import 'package:iveco_find/src/shared/models/user_model.dart';
import 'package:iveco_find/src/shared/params/user_params.dart';
import 'package:iveco_find/src/shared/utils/failure.dart';

class UserRepository {
  final ClientDio dio;
  UserRepository({required this.dio});

  Future<Either<Failure, PaginationModel>> getUsers({
    required int page,
    String query = '',
    String? perfil,
    bool? ativo,
  }) async {
    try {
      final result = await dio.get(
        '/api/v1/usuarios',
        isAuth: true,
        queryParameters: {
          'pagina': page,
          'tamanhoPagina': 25,
          'ordem': 'asc',
          if (query.trim().isNotEmpty) 'q': query.trim(),
          if (perfil != null) 'perfil': perfil,
          if (ativo != null) 'ativo': ativo.toString(),
        },
      );
      return Right(
        PaginationModel.fromJson(
          result.data,
          list: result.data['itens']
              .map<UserModel>((e) => UserModel.fromJson(e))
              .toList(),
        ),
      );
    } catch (e) {
      return Left(_failure(e, 'Falha ao buscar usuários.'));
    }
  }

  Future<Either<Failure, UserModel>> getUser(String id) async {
    try {
      final result = await dio.get('/api/v1/usuarios/$id', isAuth: true);
      return Right(UserModel.fromJson(result.data));
    } catch (e) {
      return Left(_failure(e, 'Falha ao buscar usuário.'));
    }
  }

  Future<Either<Failure, ProvisionalPasswordModel>> createUser(
    UserParams params,
  ) async {
    try {
      final result = await dio.post(
        '/api/v1/usuarios',
        isAuth: true,
        data: params.toCreateJson(),
      );
      return Right(ProvisionalPasswordModel.fromJson(result.data));
    } catch (e) {
      return Left(_failure(e, 'Falha ao cadastrar usuário.'));
    }
  }

  Future<Either<Failure, UserModel>> updateUser(
    String id,
    Map<String, dynamic> json,
  ) async {
    try {
      final result = await dio.patch(
        '/api/v1/usuarios/$id',
        isAuth: true,
        data: json,
      );
      return Right(UserModel.fromJson(result.data));
    } catch (e) {
      return Left(_failure(e, 'Falha ao atualizar usuário.'));
    }
  }

  Future<Either<Failure, ProvisionalPasswordModel>> resetPassword(
    String id,
  ) async {
    try {
      final result = await dio.post(
        '/api/v1/usuarios/$id/senha-provisoria',
        isAuth: true,
      );
      return Right(ProvisionalPasswordModel.fromJson(result.data));
    } catch (e) {
      return Left(_failure(e, 'Falha ao redefinir senha.'));
    }
  }

  /// Lê o Problem Details da API: `detail` e, se houver, a mensagem do primeiro campo.
  Failure _failure(Object error, String fallback) {
    if (error is DioException && error.response?.data is Map) {
      final data = error.response!.data as Map;
      final campos = data['campos'] as List?;
      String? message = data['detail'] as String?;
      if (campos != null && campos.isNotEmpty) {
        message = '${campos.first['campo']}: ${campos.first['mensagem']}';
      }
      return Failure(
        message: message ?? fallback,
        code: data['codigo'] as String?,
      );
    }
    return Failure(message: fallback);
  }
}
