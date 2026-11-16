import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:iveco_find/src/core/services/dio_client.dart';
import 'package:iveco_find/src/shared/models/dashboard_summary_model.dart';
import 'package:iveco_find/src/shared/models/location_count_model.dart';
import 'package:iveco_find/src/shared/repositories/dashboard_repository.dart';
import 'package:iveco_find/src/shared/utils/failure.dart';

Map<String, dynamic> summaryJson({
  int disponivel = 2,
  int emUso = 3,
  int emManutencao = 1,
  int baixado = 1,
  List<Map<String, dynamic>>? porTipo,
  String valor = '1234.50',
  int semValor = 1,
}) => {
  'total': disponivel + emUso + emManutencao,
  'porStatus': {
    'DISPONIVEL': disponivel,
    'EM_USO': emUso,
    'EM_MANUTENCAO': emManutencao,
    'BAIXADO': baixado,
  },
  'porTipo':
      porTipo ??
      [
        {
          'tipoAtivo': {'id': 't1', 'nome': 'Furadeira'},
          'quantidade': 4,
        },
        {
          'tipoAtivo': {'id': 't2', 'nome': 'Notebook'},
          'quantidade': 2,
        },
      ],
  'valor': {'total': valor, 'ativosSemValor': semValor},
};

final emptySummaryJson = summaryJson(
  disponivel: 0,
  emUso: 0,
  emManutencao: 0,
  baixado: 0,
  porTipo: [],
  valor: '0.00',
  semValor: 0,
);

Map<String, dynamic> locationJson(String id, String nome, int quantidade) => {
  'localidade': {'id': id, 'nome': nome},
  'quantidade': quantidade,
};

/// DashboardRepository falso: conta as chamadas; `summaryFailure`/`locationFailure` fazem falhar.
class FakeDashboardRepository implements DashboardRepository {
  int summaryCalls = 0;
  int locationCalls = 0;
  Failure? summaryFailure;
  Failure? locationFailure;

  /// Se definido, a chamada de `getSummary` feita agora só responde quando ele completar
  /// (com a falha/os dados vigentes no momento da chamada).
  Completer<void>? summaryGate;
  Map<String, dynamic> summary = summaryJson();
  List<Map<String, dynamic>> locations = [
    locationJson('l1', 'Betim', 2),
    locationJson('l2', 'Sete Lagoas', 4),
  ];

  @override
  ClientDio get dio => throw UnimplementedError();

  @override
  Future<Either<Failure, DashboardSummaryModel>> getSummary() async {
    summaryCalls++;
    final gate = summaryGate;
    final failure = summaryFailure;
    final data = summary;
    if (gate != null) await gate.future;
    if (failure != null) return Left(failure);
    return Right(DashboardSummaryModel.fromJson(data));
  }

  @override
  Future<Either<Failure, List<LocationCountModel>>> getByLocation() async {
    locationCalls++;
    if (locationFailure != null) return Left(locationFailure!);
    return Right(locations.map(LocationCountModel.fromJson).toList());
  }
}
