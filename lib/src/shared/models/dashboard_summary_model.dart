import 'package:iveco_find/src/shared/enums/active_status.dart';

/// Resposta de `GET /api/v1/dashboard/resumo`.
class DashboardSummaryModel {
  /// Ativos contados (DISPONIVEL + EM_USO + EM_MANUTENCAO; sem BAIXADO).
  final int total;

  /// Os 4 Status sempre presentes (inclusive BAIXADO e zeros).
  final Map<ActiveStatus, int> byStatus;

  /// Até 5 Tipos, quantidade desc.
  final List<TypeCountModel> byType;

  /// Valor patrimonial: string decimal da API com 2 casas ("1234.50").
  final String totalValue;
  final int withoutValue;

  DashboardSummaryModel({
    required this.total,
    required this.byStatus,
    required this.byType,
    required this.totalValue,
    required this.withoutValue,
  });

  int get inUse => byStatus[ActiveStatus.emUso] ?? 0;

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    final status = json['porStatus'] as Map<String, dynamic>;
    final valor = json['valor'] as Map<String, dynamic>;
    return DashboardSummaryModel(
      total: json['total'] as int,
      byStatus: {
        for (final s in ActiveStatus.values) s: (status[s.value] as int?) ?? 0,
      },
      byType: (json['porTipo'] as List)
          .map((e) => TypeCountModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalValue: valor['total'] as String,
      withoutValue: valor['ativosSemValor'] as int,
    );
  }
}

class TypeCountModel {
  final String id;
  final String nome;
  final int quantidade;

  TypeCountModel({
    required this.id,
    required this.nome,
    required this.quantidade,
  });

  factory TypeCountModel.fromJson(Map<String, dynamic> json) {
    final tipo = json['tipoAtivo'] as Map<String, dynamic>;
    return TypeCountModel(
      id: tipo['id'] as String,
      nome: tipo['nome'] as String,
      quantidade: json['quantidade'] as int,
    );
  }
}
