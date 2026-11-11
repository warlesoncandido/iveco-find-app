import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:iveco_find/src/modules/public/public_active_model.dart';
import 'package:iveco_find/src/shared/utils/failure.dart';

/// Consulta pública do Ativo, sem autenticação. Usa um [Dio] próprio (sem o `ClientDio`,
/// que depende de storage e do interceptor de auth).
class PublicActiveRepository {
  PublicActiveRepository({Dio? dio}) : dio = dio ?? Dio(_defaultOptions());

  final Dio dio;

  /// Código da [Failure] quando a API responde 404.
  static const notFound = 'NOT_FOUND';

  /// `--dart-define=PUBLIC_API_URL=...`; sem ele, a origem da própria página.
  static String baseUrl() {
    const fromEnv = String.fromEnvironment('PUBLIC_API_URL');
    if (fromEnv.isNotEmpty) return fromEnv;
    // `origin` só existe em http(s); fora do navegador (testes) fica vazio.
    final base = Uri.base;
    return base.isScheme('http') || base.isScheme('https') ? base.origin : '';
  }

  static BaseOptions _defaultOptions() {
    const timeout = Duration(seconds: 30);
    return BaseOptions(
      baseUrl: baseUrl(),
      connectTimeout: timeout,
      receiveTimeout: timeout,
      sendTimeout: timeout,
    );
  }

  Future<Either<Failure, PublicActive>> fetch(String id) async {
    try {
      final result = await dio.get<Map<String, dynamic>>(
        '/api/v1/publico/ativos/${Uri.encodeComponent(id)}',
      );
      return Right(PublicActive.fromJson(result.data!));
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return Left(Failure(message: 'Ativo não encontrado', code: notFound));
      }
      return Left(Failure(message: 'Não foi possível carregar o ativo.'));
    } catch (_) {
      return Left(Failure(message: 'Não foi possível carregar o ativo.'));
    }
  }
}
