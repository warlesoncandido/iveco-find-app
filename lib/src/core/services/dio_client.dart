import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:iveco_find/src/core/services/i_local_storage.dart';
import 'package:iveco_find/src/shared/models/auth_model.dart';

class ClientDio {
  ClientDio({
    required LocalStorage storage,
    Duration timeout = const Duration(seconds: 30),
  }) : _dio = Dio() {
    _dio.options
      ..baseUrl = _baseUrl
      ..connectTimeout = timeout
      ..receiveTimeout = timeout
      ..sendTimeout = timeout;

    _dio.interceptors.addAll([_AuthInterceptor(storage), LogInterceptor()]);
  }

  static const tokenKey = 'auth';
  static const _baseUrl = String.fromEnvironment('BASE_URL');

  final Dio _dio;

  Future<Response<T>> get<T>(
    String path, {
    bool isAuth = false,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: _withAuth(options, isAuth),
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    bool isAuth = false,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: _withAuth(options, isAuth),
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    bool isAuth = false,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: _withAuth(options, isAuth),
    );
  }

  Future<Response<T>> patch<T>(
    String path, {
    bool isAuth = false,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: _withAuth(options, isAuth),
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    bool isAuth = false,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: _withAuth(options, isAuth),
    );
  }

  Options _withAuth(Options? options, bool isAuth) {
    final opts = options ?? Options();
    return opts.copyWith(
      extra: {...?opts.extra, _AuthInterceptor.isAuthKey: isAuth},
    );
  }
}

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._storage);

  static const isAuthKey = 'isAuth';

  final LocalStorage _storage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra[isAuthKey] == true) {
      final token = await _storage.getString(ClientDio.tokenKey);
      if (token != null && token.isNotEmpty) {
        final auth = AuthModel.fromJson(json.decode(token));
        options.headers['Authorization'] = 'Bearer ${auth.token}';
      }
    }
    options.extra.remove(isAuthKey);
    handler.next(options);
  }
}
