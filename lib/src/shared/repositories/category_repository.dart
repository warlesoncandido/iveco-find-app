import 'package:dartz/dartz.dart';
import 'package:iveco_find/src/core/services/dio_client.dart';
import 'package:iveco_find/src/shared/models/category_model.dart';
import 'package:iveco_find/src/shared/utils/failure.dart';

class CategoryRepository {
  final ClientDio dio;
  CategoryRepository({required this.dio});

  Future<Either<Failure, List<CategoryModel>>> getSelectableCategories() async {
    try {
      final result = await dio.get(
        '/api/v1/categorias?pagina=1&tamanhoPagina=100&ordem=asc',
        isAuth: true,
      );
      return Right(
        result.data['itens']
            .map<CategoryModel>((e) => CategoryModel.fromJson(e))
            .toList(),
      );
    } catch (e) {
      return Left(Failure(message: 'Falha ao buscar categorias.'));
    }
  }

  Future<Either<Failure, List<CategoryModel>>> getSelectableSubcategories(
    String categoryId,
  ) async {
    try {
      final result = await dio.get(
        '/api/v1/categorias/$categoryId/subcategorias?pagina=1&tamanhoPagina=100&ordem=asc',
        isAuth: true,
      );
      return Right(
        result.data['itens']
            .map<CategoryModel>((e) => CategoryModel.fromJson(e))
            .toList(),
      );
    } catch (e) {
      return Left(Failure(message: 'Falha ao buscar subcategorias.'));
    }
  }
}
