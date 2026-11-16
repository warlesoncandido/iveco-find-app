import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:iveco_find/src/core/l10n/locale_controller.dart';
import 'package:iveco_find/src/core/services/dio_client.dart';
import 'package:iveco_find/src/shared/models/dashboard_summary_model.dart';
import 'package:iveco_find/src/shared/models/location_count_model.dart';
import 'package:iveco_find/src/shared/utils/failure.dart';

class DashboardRepository {
  final ClientDio dio;
  DashboardRepository({required this.dio});

  Future<Either<Failure, DashboardSummaryModel>> getSummary() async {
    try {
      final result = await dio.get('/api/v1/dashboard/resumo', isAuth: true);
      return Right(DashboardSummaryModel.fromJson(result.data));
    } catch (e) {
      return Left(_failure(e, L10n.current.dashboardSummaryFetchError));
    }
  }

  Future<Either<Failure, List<LocationCountModel>>> getByLocation() async {
    try {
      final result = await dio.get(
        '/api/v1/dashboard/ativos-por-localidade',
        isAuth: true,
      );
      return Right(
        (result.data as List)
            .map((e) => LocationCountModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } catch (e) {
      return Left(_failure(e, L10n.current.dashboardByLocationFetchError));
    }
  }

  /// Lê o Problem Details da API (`detail` e `codigo`).
  Failure _failure(Object error, String fallback) {
    if (error is DioException && error.response?.data is Map) {
      final data = error.response!.data as Map;
      return Failure(
        message: (data['detail'] as String?) ?? fallback,
        code: data['codigo'] as String?,
      );
    }
    return Failure(message: fallback);
  }
}
