import 'package:iveco_find/src/shared/enums/active_status.dart';
import 'package:iveco_find/src/shared/enums/movement_type.dart';
import 'package:iveco_find/src/shared/models/ref_model.dart';
import 'package:iveco_find/src/shared/utils/helpers/date_helper.dart';
import 'package:iveco_find/src/shared/utils/helpers/money_helper.dart';

class ActiveHistoryModel {
  final String id;
  final String tipo;
  final MovementType? tipoMovimentacao;
  final RefModel autor;
  final DateTime ocorridoEm;
  final int versaoAtivo;
  final String? observacao;
  final List<HistoryChangeModel> mudancas;

  ActiveHistoryModel({
    required this.id,
    required this.tipo,
    required this.tipoMovimentacao,
    required this.autor,
    required this.ocorridoEm,
    required this.versaoAtivo,
    required this.observacao,
    required this.mudancas,
  });

  String get title {
    if (tipoMovimentacao != null) {
      return tipoMovimentacao!.label;
    }
    return switch (tipo) {
      'ALTERACAO' => 'Alteração',
      'EXCLUSAO' => 'Exclusão',
      'RESTAURACAO' => 'Restauração',
      _ => 'Movimentação',
    };
  }

  factory ActiveHistoryModel.fromJson(Map<String, dynamic> json) {
    return ActiveHistoryModel(
      id: json['id'] as String,
      tipo: json['tipo'] as String,
      tipoMovimentacao: json['tipoMovimentacao'] != null
          ? MovementType.fromValue(json['tipoMovimentacao'] as String)
          : null,
      autor: RefModel.fromJson(json['autor']),
      ocorridoEm: DateTime.parse(json['ocorridoEm'] as String),
      versaoAtivo: json['versaoAtivo'] as int,
      observacao: json['observacao'] as String?,
      mudancas: (json['mudancas'] as List)
          .map((e) => HistoryChangeModel.fromJson(e))
          .toList(),
    );
  }
}

class HistoryChangeModel {
  final String campo;
  final dynamic antes;
  final dynamic depois;

  HistoryChangeModel({
    required this.campo,
    required this.antes,
    required this.depois,
  });

  static const _labels = {
    'nome': 'Nome',
    'codigoSap': 'Código SAP',
    'numeroSerie': 'Número de série',
    'patrimonio': 'Patrimônio',
    'tipoAtivoId': 'Tipo',
    'categoriaId': 'Categoria',
    'subcategoriaId': 'Subcategoria',
    'marca': 'Marca',
    'modelo': 'Modelo',
    'setorId': 'Setor',
    'responsavel': 'Responsável',
    'status': 'Status',
    'dataEntrada': 'Data de entrada',
    'dataAquisicao': 'Data de aquisição',
    'valor': 'Valor',
    'fornecedorId': 'Fornecedor',
    'vidaUtilMeses': 'Vida útil (meses)',
  };

  String get label => _labels[campo] ?? campo;

  String get formattedBefore => _format(antes);
  String get formattedAfter => _format(depois);

  String _format(dynamic value) {
    if (value == null) return '—';
    if (value is Map) return value['rotulo'].toString();
    return switch (campo) {
      'status' => ActiveStatus.fromValue(value).label,
      'valor' => MoneyHelper.formatMoney(double.parse(value)),
      'dataEntrada' || 'dataAquisicao' => DateHelper.toBr(value),
      _ => value.toString(),
    };
  }

  factory HistoryChangeModel.fromJson(Map<String, dynamic> json) {
    return HistoryChangeModel(
      campo: json['campo'] as String,
      antes: json['antes'],
      depois: json['depois'],
    );
  }
}
