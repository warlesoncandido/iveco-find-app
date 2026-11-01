import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:iveco_find/src/core/services/dio_client.dart';
import 'package:iveco_find/src/shared/models/pagination_model.dart';
import 'package:iveco_find/src/shared/models/section_model.dart';
import 'package:iveco_find/src/shared/params/section_params.dart';
import 'package:iveco_find/src/shared/utils/failure.dart';

class SectionRepository {
  final ClientDio dio;
  SectionRepository({required this.dio});

  Future<Either<Failure, PaginationModel>> getAllSectionByLocation({
    required String locationId,
    required int page,
  }) async {
    try {
      final result = await dio.get(
        '/api/v1/localidades/$locationId/setores?pagina=$page&tamanhoPagina=25&ordem=asc&q=&incluirInativos=true',
        isAuth: true,
      );
      return Right(
        PaginationModel.fromJson(
          result.data,
          list: result.data['itens']
              .map<SectionModel>((e) => SectionModel.fromJson(e))
              .toList(),
        ),
      );
    } catch (e) {
      return Left(Failure(message: 'Falha ao buscar setores.'));
    }
  }

  Future<Either<Failure, bool>> saveSection(
    SectionParams params,
    String locationId,
  ) async {
    try {
      await dio.post(
        '/api/v1/localidades/$locationId/setores',
        isAuth: true,
        data: params.toJson(),
      );
      return Right(true);
    } on DioException catch (error) {
      String message =
          error.response?.data['detail'] ?? 'Falha ao cadastrar setor.';
      return Left(Failure(message: message));
    }
  }

  Future<Either<Failure, bool>> updateSection(
    SectionParams params,
    String locationId,
    String id,
  ) async {
    try {
      await dio.patch(
        '/api/v1/localidades/$locationId/setores/$id',
        isAuth: true,
        data: params.toJson(),
      );
      return Right(true);
    } on DioException catch (error) {
      String message =
          error.response?.data['detail'] ?? 'Falha ao atualizar setor.';
      return Left(Failure(message: message));
    }
  }

  /// Só os ativos, para seleção no cadastro de Ativo.
  Future<Either<Failure, List<SectionModel>>> getSelectableSections(
    String locationId,
  ) async {
    try {
      final result = await dio.get(
        '/api/v1/localidades/$locationId/setores?pagina=1&tamanhoPagina=100&ordem=asc',
        isAuth: true,
      );
      return Right(
        result.data['itens']
            .map<SectionModel>((e) => SectionModel.fromJson(e))
            .toList(),
      );
    } catch (e) {
      return Left(Failure(message: 'Falha ao buscar setores.'));
    }
  }
}
