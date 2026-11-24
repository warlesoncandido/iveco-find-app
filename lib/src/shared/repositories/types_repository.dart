import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:iveco_find/src/core/l10n/locale_controller.dart';
import 'package:iveco_find/src/core/services/dio_client.dart';
import 'package:iveco_find/src/shared/models/pagination_model.dart';
import 'package:iveco_find/src/shared/models/type_model.dart';
import 'package:iveco_find/src/shared/params/type_params.dart';
import 'package:iveco_find/src/shared/utils/failure.dart';
import 'package:iveco_find/src/shared/utils/helpers/session_helper.dart';

class TypesRepository {
  final ClientDio dio;
  TypesRepository({required this.dio});

  /// `query` casa com o nome ou o Prefixo do Tipo (na API).
  Future<Either<Failure, PaginationModel>> getTypes({
    required int page,
    String query = '',
  }) async {
    try {
      final result = await dio.get(
        '/api/v1/tipos-ativo',
        isAuth: true,
        queryParameters: await SessionHelper.listQuery(
          page: page,
          query: query,
        ),
      );
      return Right(
        PaginationModel.fromJson(
          result.data,
          list: result.data['itens']
              .map<TypeModel>((e) => TypeModel.fromJson(e))
              .toList(),
        ),
      );
    } catch (e) {
      return Left(Failure(message: L10n.current.typesFetchError));
    }
  }

  Future<Either<Failure, bool>> saveType(TypeParams params) async {
    try {
      await dio.post(
        '/api/v1/tipos-ativo',
        isAuth: true,
        data: params.toJson(),
      );
      return Right(true);
    } on DioException catch (error) {
      String message =
          error.response?.data['detail'] ?? L10n.current.typeCreateError;
      return Left(Failure(message: message));
    }
  }

  Future<Either<Failure, bool>> updateType(TypeParams params, String id) async {
    try {
      await dio.patch(
        '/api/v1/tipos-ativo/$id',
        isAuth: true,
        data: params.toJson(),
      );
      return Right(true);
    } on DioException catch (error) {
      String message =
          error.response?.data['detail'] ?? L10n.current.typeUpdateError;
      return Left(Failure(message: message));
    }
  }

  /// Só os ativos, para seleção no cadastro de Ativo.
  Future<Either<Failure, List<TypeModel>>> getSelectableTypes() async {
    try {
      final result = await dio.get(
        '/api/v1/tipos-ativo?pagina=1&tamanhoPagina=100&ordem=asc',
        isAuth: true,
      );
      return Right(
        result.data['itens']
            .map<TypeModel>((e) => TypeModel.fromJson(e))
            .toList(),
      );
    } catch (e) {
      return Left(Failure(message: L10n.current.typesFetchError));
    }
  }
}
