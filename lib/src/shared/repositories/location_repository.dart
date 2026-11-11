import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:iveco_find/src/core/services/dio_client.dart';
import 'package:iveco_find/src/shared/models/location_model.dart';
import 'package:iveco_find/src/shared/models/pagination_model.dart';
import 'package:iveco_find/src/shared/params/location_params.dart';
import 'package:iveco_find/src/shared/utils/failure.dart';
import 'package:iveco_find/src/shared/utils/helpers/session_helper.dart';

class LocationRepository {
  final ClientDio dio;
  LocationRepository({required this.dio});

  Future<Either<Failure, PaginationModel>> getAllLocations({
    required int page,
  }) async {
    try {
      final result = await dio.get(
        '/api/v1/localidades?pagina=$page&tamanhoPagina=25&ordem=asc&q=${await SessionHelper.includeInactiveQuery()}',
        isAuth: true,
      );
      return Right(
        PaginationModel.fromJson(
          result.data,
          list: result.data['itens']
              .map<LocationModel>((e) => LocationModel.fromJson(e))
              .toList(),
        ),
      );
    } catch (e) {
      return Left(Failure(message: 'Falha ao buscar localidades.'));
    }
  }

  Future<Either<Failure, bool>> saveLocation(LocationParams params) async {
    try {
      await dio.post(
        '/api/v1/localidades',
        isAuth: true,
        data: params.toJson(),
      );
      return Right(true);
    } on DioException catch (error) {
      String message =
          error.response?.data['detail'] ?? 'Falha ao cadastrar localidade.';
      return Left(Failure(message: message));
    }
  }

  Future<Either<Failure, bool>> updateLocation(
    LocationParams params,
    String id,
  ) async {
    try {
      await dio.patch(
        '/api/v1/localidades/$id',
        isAuth: true,
        data: params.toJson(),
      );
      return Right(true);
    } on DioException catch (error) {
      String message =
          error.response?.data['detail'] ?? 'Falha ao atualizar localidade.';
      return Left(Failure(message: message));
    }
  }

  /// Só os ativos, para seleção no cadastro de Ativo.
  Future<Either<Failure, List<LocationModel>>> getSelectableLocations() async {
    try {
      final result = await dio.get(
        '/api/v1/localidades?pagina=1&tamanhoPagina=100&ordem=asc',
        isAuth: true,
      );
      return Right(
        result.data['itens']
            .map<LocationModel>((e) => LocationModel.fromJson(e))
            .toList(),
      );
    } catch (e) {
      return Left(Failure(message: 'Falha ao buscar localidades.'));
    }
  }
}
