import 'package:iveco_find/l10n/app_localizations.dart';
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

  String title(AppLocalizations l) {
    if (tipoMovimentacao != null) {
      return tipoMovimentacao!.label(l);
    }
    return switch (tipo) {
      'ALTERACAO' => l.historyChange,
      'EXCLUSAO' => l.historyDeletion,
      'RESTAURACAO' => l.historyRestore,
      _ => l.historyMovement,
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

  /// Rótulo do campo alterado; campo desconhecido aparece como veio da API.
  String label(AppLocalizations l) => switch (campo) {
    'nome' => l.fieldName,
    'codigoSap' => l.fieldSapCode,
    'numeroSerie' => l.fieldSerialNumber,
    'patrimonio' => l.fieldPatrimony,
    'tipoAtivoId' => l.fieldType,
    'categoriaId' => l.fieldCategory,
    'subcategoriaId' => l.fieldSubcategory,
    'marca' => l.fieldBrand,
    'modelo' => l.fieldModel,
    'setorId' => l.fieldSection,
    'responsavel' => l.fieldResponsible,
    'status' => l.fieldStatus,
    'dataEntrada' => l.fieldEntryDate,
    'dataAquisicao' => l.fieldAcquisitionDate,
    'valor' => l.fieldValue,
    'fornecedorId' => l.fieldSupplier,
    'vidaUtilMeses' => l.fieldUsefulLifeMonths,
    _ => campo,
  };

  String formattedBefore(AppLocalizations l) => _format(antes, l);
  String formattedAfter(AppLocalizations l) => _format(depois, l);

  String _format(dynamic value, AppLocalizations l) {
    if (value == null) return l.commonEmptyValue;
    if (value is Map) return value['rotulo'].toString();
    return switch (campo) {
      'status' => ActiveStatus.fromValue(value).label(l),
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
