import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:iveco_find/src/core/services/dio_client.dart';
import 'package:iveco_find/src/core/services/i_local_storage.dart';
import 'package:iveco_find/src/shared/models/pagination_model.dart';
import 'package:iveco_find/src/shared/models/provisional_password_model.dart';
import 'package:iveco_find/src/shared/models/user_model.dart';
import 'package:iveco_find/src/shared/params/user_params.dart';
import 'package:iveco_find/src/shared/repositories/auth_repository.dart';
import 'package:iveco_find/src/shared/repositories/user_repository.dart';
import 'package:iveco_find/src/shared/utils/failure.dart';

class DioCall {
  final String method;
  final String path;
  final Map<String, dynamic>? queryParameters;
  final Object? data;
  final bool isAuth;
  DioCall(this.method, this.path, this.queryParameters, this.data, this.isAuth);
}

/// ClientDio falso: grava as chamadas e devolve `response` ou lança `error`.
class FakeClientDio implements ClientDio {
  final calls = <DioCall>[];
  Object? response;
  Object? error;

  Future<Response<T>> _handle<T>(
    String method,
    String path,
    Map<String, dynamic>? queryParameters,
    Object? data,
    bool isAuth,
  ) async {
    calls.add(DioCall(method, path, queryParameters, data, isAuth));
    if (error != null) throw error!;
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      statusCode: 200,
      data: response as T,
    );
  }

  @override
  Future<Response<T>> get<T>(
    String path, {
    bool isAuth = false,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) => _handle<T>('GET', path, queryParameters, null, isAuth);

  @override
  Future<Response<T>> post<T>(
    String path, {
    bool isAuth = false,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) => _handle<T>('POST', path, queryParameters, data, isAuth);

  @override
  Future<Response<T>> put<T>(
    String path, {
    bool isAuth = false,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) => _handle<T>('PUT', path, queryParameters, data, isAuth);

  @override
  Future<Response<T>> patch<T>(
    String path, {
    bool isAuth = false,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) => _handle<T>('PATCH', path, queryParameters, data, isAuth);

  @override
  Future<Response<T>> delete<T>(
    String path, {
    bool isAuth = false,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) => _handle<T>('DELETE', path, queryParameters, data, isAuth);
}

DioException problemDetails(int status, String codigo, String detail) {
  final options = RequestOptions(path: '/api/v1/usuarios');
  return DioException(
    requestOptions: options,
    type: DioExceptionType.badResponse,
    response: Response(
      requestOptions: options,
      statusCode: status,
      data: {
        'type': 'about:blank',
        'title': 'Erro',
        'status': status,
        'detail': detail,
        'codigo': codigo,
      },
    ),
  );
}

class FakeLocalStorage implements LocalStorage {
  final values = <String, String>{};

  @override
  Future<String?> getString(String key) async => values[key];

  @override
  Future<void> setString(String key, String value) async => values[key] = value;

  @override
  Future<void> remove(String key) async => values.remove(key);
}

class FakeAuthRepository implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<Either<Failure, bool>> logout() async => const Right(true);
}

UserModel user({
  String id = 'u1',
  String nome = 'Maria',
  String email = 'maria@iveco.com',
  String perfil = 'GESTOR',
  bool ativo = true,
}) => UserModel(id: id, nome: nome, email: email, perfil: perfil, ativo: ativo);

final password = ProvisionalPasswordModel(
  senhaProvisoria: 'Abc123!x',
  senhaProvisoriaExpiraEm: DateTime.utc(2026, 11, 4, 12),
);

class GetUsersCall {
  final int page;
  final String query;
  final String? perfil;
  final bool? ativo;
  GetUsersCall(this.page, this.query, this.perfil, this.ativo);
}

/// UserRepository falso: grava as chamadas; `failure` != null faz tudo falhar.
class FakeUserRepository implements UserRepository {
  final getUsersCalls = <GetUsersCall>[];
  final getUserCalls = <String>[];
  final createCalls = <UserParams>[];
  final updateCalls = <MapEntry<String, Map<String, dynamic>>>[];
  final resetCalls = <String>[];

  Failure? failure;
  UserModel stored = user();

  /// Se definido, `getUser` só responde quando ele completar.
  Completer<void>? getUserGate;

  /// Se definido, `getUsers` só responde quando ele completar.
  Completer<void>? getUsersGate;
  List<UserModel> items = [user()];

  @override
  ClientDio get dio => throw UnimplementedError();

  @override
  Future<Either<Failure, PaginationModel>> getUsers({
    required int page,
    String query = '',
    String? perfil,
    bool? ativo,
  }) async {
    getUsersCalls.add(GetUsersCall(page, query, perfil, ativo));
    final gate = getUsersGate;
    final snapshot = items;
    if (gate != null) await gate.future;
    if (failure != null) return Left(failure!);
    return Right(
      PaginationModel(
        total: items.length,
        page: page,
        maxPerPage: 25,
        items: snapshot,
      ),
    );
  }

  @override
  Future<Either<Failure, UserModel>> getUser(String id) async {
    getUserCalls.add(id);
    if (getUserGate != null) await getUserGate!.future;
    if (failure != null) return Left(failure!);
    return Right(stored);
  }

  @override
  Future<Either<Failure, ProvisionalPasswordModel>> createUser(
    UserParams params,
  ) async {
    createCalls.add(params);
    if (failure != null) return Left(failure!);
    return Right(password);
  }

  @override
  Future<Either<Failure, UserModel>> updateUser(
    String id,
    Map<String, dynamic> json,
  ) async {
    updateCalls.add(MapEntry(id, json));
    if (failure != null) return Left(failure!);
    return Right(stored);
  }

  @override
  Future<Either<Failure, ProvisionalPasswordModel>> resetPassword(
    String id,
  ) async {
    resetCalls.add(id);
    if (failure != null) return Left(failure!);
    return Right(password);
  }
}
