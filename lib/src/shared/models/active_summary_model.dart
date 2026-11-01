import 'package:iveco_find/src/shared/enums/active_status.dart';
import 'package:iveco_find/src/shared/models/ref_model.dart';

class ActiveSummaryModel {
  final String id;
  final String codigoInterno;
  final String nome;
  final ActiveStatus status;
  final RefModel tipoAtivo;
  final RefModel categoria;
  final RefModel setor;
  final RefModel localidade;
  final String? responsavel;
  final DateTime ultimaMovimentacaoEm;
  final int versao;

  ActiveSummaryModel({
    required this.id,
    required this.codigoInterno,
    required this.nome,
    required this.status,
    required this.tipoAtivo,
    required this.categoria,
    required this.setor,
    required this.localidade,
    required this.responsavel,
    required this.ultimaMovimentacaoEm,
    required this.versao,
  });

  factory ActiveSummaryModel.fromJson(Map<String, dynamic> json) {
    return ActiveSummaryModel(
      id: json['id'] as String,
      codigoInterno: json['codigoInterno'] as String,
      nome: json['nome'] as String,
      status: ActiveStatus.fromValue(json['status'] as String),
      tipoAtivo: RefModel.fromJson(json['tipoAtivo']),
      categoria: RefModel.fromJson(json['categoria']),
      setor: RefModel.fromJson(json['setor']),
      localidade: RefModel.fromJson(json['localidade']),
      responsavel: json['responsavel'] as String?,
      ultimaMovimentacaoEm: DateTime.parse(
        json['ultimaMovimentacaoEm'] as String,
      ),
      versao: json['versao'] as int,
    );
  }
}
