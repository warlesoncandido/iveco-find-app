import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:iveco_find/src/core/services/i_local_storage.dart';
import 'package:iveco_find/src/shared/models/auth_model.dart';

class ClientDio {
  /// [onSessionExpired] é chamado quando a renovação da sessão é recusada pela API
  /// (refresh inválido, revogado ou vencido): o `auth` salvo já foi removido.
  ClientDio({
    required LocalStorage storage,
    Duration timeout = const Duration(seconds: 30),
    VoidCallback? onSessionExpired,
    @visibleForTesting HttpClientAdapter? httpClientAdapter,
    @visibleForTesting String baseUrl = _baseUrl,
  }) : _dio = Dio() {
    _dio.options
      ..baseUrl = baseUrl
      ..connectTimeout = timeout
      ..receiveTimeout = timeout
      ..sendTimeout = timeout;

    // Dio cru e próprio para o refresh: sem o interceptor de auth (sem loop) e sem
    // depender do AuthRepository, que depende deste ClientDio.
    final refreshDio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: timeout,
        receiveTimeout: timeout,
        sendTimeout: timeout,
      ),
    )..interceptors.add(LogInterceptor());

    if (httpClientAdapter != null) {
      _dio.httpClientAdapter = httpClientAdapter;
      refreshDio.httpClientAdapter = httpClientAdapter;
    }

    _dio.interceptors.addAll([
      _AuthInterceptor(
        storage: storage,
        dio: _dio,
        refreshDio: refreshDio,
        onSessionExpired: onSessionExpired,
      ),
      LogInterceptor(),
    ]);
  }

  static const tokenKey = 'auth';
  static const refreshPath = '/api/v1/auth/refresh';
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

/// Resultado da renovação compartilhado entre as requisições 401 concorrentes.
enum _RefreshResult {
  /// Novo par gravado: refazer a requisição.
  renewed,

  /// A API recusou o refresh (ou não há refresh salvo): sessão limpa, ir ao login.
  expired,

  /// Falha de rede ou resposta inesperada: propagar o erro original, sem limpar a sessão.
  failed,
}

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor({
    required LocalStorage storage,
    required Dio dio,
    required Dio refreshDio,
    VoidCallback? onSessionExpired,
  }) : _storage = storage,
       _dio = dio,
       _refreshDio = refreshDio,
       _onSessionExpired = onSessionExpired;

  static const isAuthKey = 'isAuth';

  /// Token Bearer enviado na requisição (só em requisições autenticadas).
  static const _sentTokenKey = '_authSentToken';

  /// A requisição já foi refeita depois de um 401: não renova de novo.
  static const _retriedKey = '_authRetried';

  final LocalStorage _storage;
  final Dio _dio;
  final Dio _refreshDio;
  final VoidCallback? _onSessionExpired;

  /// Renovação em voo (single-flight): os 401 concorrentes aguardam o mesmo resultado.
  Completer<_RefreshResult>? _refreshing;

  Future<AuthModel?> _readAuth() async {
    final raw = await _storage.getString(ClientDio.tokenKey);
    if (raw == null || raw.isEmpty) return null;
    return AuthModel.fromJson(json.decode(raw));
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra[isAuthKey] == true) {
      final auth = await _readAuth();
      if (auth != null) {
        options.headers['Authorization'] = 'Bearer ${auth.token}';
        options.extra[_sentTokenKey] = auth.token;
      }
    }
    options.extra.remove(isAuthKey);
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final sentToken = options.extra[_sentTokenKey];
    if (err.response?.statusCode != 401 ||
        sentToken == null ||
        options.extra[_retriedKey] == true ||
        options.path == ClientDio.refreshPath) {
      return handler.next(err);
    }

    // Outra requisição já renovou depois que esta saiu: só refaz com o token novo.
    final current = await _readAuth();
    if (current == null) return handler.next(err);
    if (current.token == sentToken) {
      final result = await _refreshOnce(current);
      if (result != _RefreshResult.renewed) return handler.next(err);
    }

    try {
      options.extra
        ..[isAuthKey] = true
        ..[_retriedKey] = true;
      // O onRequest põe o token atual; sem auth salvo, não reenvia o antigo.
      options.headers.remove('Authorization');
      handler.resolve(await _dio.fetch<dynamic>(options));
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  Future<_RefreshResult> _refreshOnce(AuthModel auth) {
    final running = _refreshing;
    if (running != null) return running.future;

    final completer = _refreshing = Completer<_RefreshResult>();
    _refresh(auth)
        .then(
          completer.complete,
          onError: (_) => completer.complete(_RefreshResult.failed),
        )
        .whenComplete(() {
          if (identical(_refreshing, completer)) _refreshing = null;
        });
    return completer.future;
  }

  Future<_RefreshResult> _refresh(AuthModel auth) async {
    final refreshToken = auth.refreshToken;
    if (refreshToken == null || refreshToken.isEmpty) return _expire();

    try {
      final response = await _refreshDio.post<Map<String, dynamic>>(
        ClientDio.refreshPath,
        data: {'refreshToken': refreshToken},
      );
      final data = response.data;
      final token = data?['token'];
      final newRefresh = data?['refreshToken'];
      if (token is! String || newRefresh is! String) {
        return _RefreshResult.failed;
      }
      await _storage.setString(
        ClientDio.tokenKey,
        json.encode(
          auth.withTokens(token: token, refreshToken: newRefresh).toJson(),
        ),
      );
      return _RefreshResult.renewed;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) return _expire();
      return _RefreshResult.failed;
    } catch (_) {
      return _RefreshResult.failed;
    }
  }

  Future<_RefreshResult> _expire() async {
    // Nada aqui pode escapar: os 401 em espera dependem deste resultado.
    try {
      await _storage.remove(ClientDio.tokenKey);
    } catch (_) {}
    try {
      _onSessionExpired?.call();
    } catch (_) {}
    return _RefreshResult.expired;
  }
}
