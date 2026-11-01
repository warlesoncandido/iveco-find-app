import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:iveco_find/src/core/services/dio_client.dart';
import 'package:iveco_find/src/shared/models/active_history_model.dart';
import 'package:iveco_find/src/shared/models/active_model.dart';
import 'package:iveco_find/src/shared/models/active_summary_model.dart';
import 'package:iveco_find/src/shared/models/pagination_model.dart';
import 'package:iveco_find/src/shared/models/valid_movement_model.dart';
import 'package:iveco_find/src/shared/params/active_params.dart';
import 'package:iveco_find/src/shared/params/movement_params.dart';
import 'package:iveco_find/src/shared/utils/failure.dart';

class ActiveRepository {
  final ClientDio dio;
  ActiveRepository({required this.dio});

  static const versionConflict = 'ATIVO_VERSAO_CONFLITO';

  Future<Either<Failure, PaginationModel>> getActives({
    required int page,
    String query = '',
    String? status,
  }) async {
    try {
      final result = await dio.get(
        '/api/v1/ativos',
        isAuth: true,
        queryParameters: {
          'pagina': page,
          'tamanhoPagina': 25,
          'ordem': 'asc',
          'q': query,
          if (status != null) 'status': status,
        },
      );
      return Right(
        PaginationModel.fromJson(
          result.data,
          list: result.data['itens']
              .map<ActiveSummaryModel>((e) => ActiveSummaryModel.fromJson(e))
              .toList(),
        ),
      );
    } catch (e) {
      return Left(_failure(e, 'Falha ao buscar ativos.'));
    }
  }

  Future<Either<Failure, ActiveModel>> getActive(String id) async {
    try {
      final result = await dio.get('/api/v1/ativos/$id', isAuth: true);
      return Right(ActiveModel.fromJson(result.data));
    } catch (e) {
      return Left(_failure(e, 'Falha ao buscar ativo.'));
    }
  }

  Future<Either<Failure, ActiveModel>> saveActive(ActiveParams params) async {
    try {
      final result = await dio.post(
        '/api/v1/ativos',
        isAuth: true,
        data: params.toJson(),
      );
      return Right(ActiveModel.fromJson(result.data));
    } catch (e) {
      return Left(_failure(e, 'Falha ao cadastrar ativo.'));
    }
  }

  Future<Either<Failure, ActiveModel>> updateActive(
    ActiveParams params,
    String id,
  ) async {
    try {
      final result = await dio.patch(
        '/api/v1/ativos/$id',
        isAuth: true,
        data: params.toJson(),
      );
      return Right(ActiveModel.fromJson(result.data));
    } catch (e) {
      return Left(_failure(e, 'Falha ao atualizar ativo.'));
    }
  }

  Future<Either<Failure, PaginationModel>> getHistory({
    required String id,
    required int page,
  }) async {
    try {
      final result = await dio.get(
        '/api/v1/ativos/$id/historico?pagina=$page&tamanhoPagina=25',
        isAuth: true,
      );
      return Right(
        PaginationModel.fromJson(
          result.data,
          list: result.data['itens']
              .map<ActiveHistoryModel>((e) => ActiveHistoryModel.fromJson(e))
              .toList(),
        ),
      );
    } catch (e) {
      return Left(_failure(e, 'Falha ao buscar histórico.'));
    }
  }

  Future<Either<Failure, List<ValidMovementModel>>> getValidMovements(
    String id,
  ) async {
    try {
      final result = await dio.get(
        '/api/v1/ativos/$id/movimentacoes-validas',
        isAuth: true,
      );
      return Right(
        (result.data as List)
            .map((e) => ValidMovementModel.fromJson(e))
            .toList(),
      );
    } catch (e) {
      return Left(_failure(e, 'Falha ao buscar movimentações.'));
    }
  }

  Future<Either<Failure, ActiveModel>> moveActive(
    MovementParams params,
    String id,
  ) async {
    try {
      final result = await dio.post(
        '/api/v1/ativos/$id/movimentacoes',
        isAuth: true,
        data: params.toJson(),
      );
      return Right(ActiveModel.fromJson(result.data));
    } catch (e) {
      return Left(_failure(e, 'Falha ao registrar movimentação.'));
    }
  }

  Future<Either<Failure, ActiveModel>> writeOffActive(
    WriteOffParams params,
    String id,
  ) async {
    try {
      final result = await dio.post(
        '/api/v1/ativos/$id/baixa',
        isAuth: true,
        data: params.toJson(),
      );
      return Right(ActiveModel.fromJson(result.data));
    } catch (e) {
      return Left(_failure(e, 'Falha ao registrar baixa.'));
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
