import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:iveco_find/src/core/services/dio_client.dart';
import 'package:iveco_find/src/shared/models/pagination_model.dart';
import 'package:iveco_find/src/shared/models/supplier_model.dart';
import 'package:iveco_find/src/shared/params/supplier_params.dart';
import 'package:iveco_find/src/shared/utils/failure.dart';

class SupplierRepository {
  final ClientDio dio;

  SupplierRepository({required this.dio});

  Future<Either<Failure, PaginationModel>> getSuppliers({
    required int page,
  }) async {
    try {
      final result = await dio.get(
        '/api/v1/fornecedores?pagina=1&tamanhoPagina=25&ordem=asc&q=&incluirInativos=true',
        isAuth: true,
      );
      return Right(
        PaginationModel.fromJson(
          result.data,
          list: result.data['itens']
              .map<SupplierModel>((e) => SupplierModel.fromJson(e))
              .toList(),
        ),
      );
    } catch (e) {
      return Left(Failure(message: 'Falha ao buscar tipos.'));
    }
  }

  Future<Either<Failure, bool>> saveSupplier(SupplierParams params) async {
    try {
      await dio.post(
        '/api/v1/fornecedores',
        isAuth: true,
        data: params.toJson(),
      );
      return Right(true);
    } on DioException catch (error) {
      String message =
          error.response?.data['detail'] ?? 'Falha ao criar fornecedor.';
      return Left(Failure(message: message));
    }
  }

  Future<Either<Failure, bool>> updateSupplier(
    SupplierParams params,
    String id,
  ) async {
    try {
      await dio.patch(
        '/api/v1/fornecedores//$id',
        isAuth: true,
        data: params.toJson(),
      );
      return Right(true);
    } on DioException catch (error) {
      String message =
          error.response?.data['detail'] ?? 'Falha ao atualizar fornecedor.';
      return Left(Failure(message: message));
    }
  }
}
