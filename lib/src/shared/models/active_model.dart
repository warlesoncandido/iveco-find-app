import 'package:iveco_find/src/shared/enums/active_status.dart';
import 'package:iveco_find/src/shared/models/active_summary_model.dart';
import 'package:iveco_find/src/shared/models/ref_model.dart';

/// Referência ao Kit ao qual um item pertence.
class KitRefModel {
  final String id;
  final String codigoInterno;
  final String nome;

  KitRefModel({
    required this.id,
    required this.codigoInterno,
    required this.nome,
  });

  factory KitRefModel.fromJson(Map<String, dynamic> json) {
    return KitRefModel(
      id: json['id'] as String,
      codigoInterno: json['codigoInterno'] as String,
      nome: json['nome'] as String,
    );
  }
}

class ActiveModel {
  final String id;
  final String codigoInterno;
  final String nome;
  final String? codigoSap;
  final String? numeroSerie;
  final String? patrimonio;
  final RefModel tipoAtivo;
  final RefModel? categoria;
  final RefModel? subcategoria;
  final String? marca;
  final String? modelo;
  final RefModel setor;
  final RefModel localidade;
  final String? responsavel;
  final ActiveStatus status;
  final String dataEntrada;
  final String? dataAquisicao;
  final String? valor;
  final RefModel? fornecedor;
  final int? vidaUtilMeses;
  final DateTime ultimaMovimentacaoEm;
  final RefModel ultimaMovimentacaoPor;
  final int versao;
  final DateTime criadoEm;
  final DateTime atualizadoEm;

  /// O Tipo do Ativo é marcado como Kit: aceita itens associados.
  final bool isKit;

  /// Kit ao qual o Ativo pertence como item.
  final KitRefModel? kit;

  /// Itens associados (só em Kit).
  final List<ActiveSummaryModel> items;

  ActiveModel({
    required this.id,
    required this.codigoInterno,
    required this.nome,
    required this.codigoSap,
    required this.numeroSerie,
    required this.patrimonio,
    required this.tipoAtivo,
    required this.categoria,
    required this.subcategoria,
    required this.marca,
    required this.modelo,
    required this.setor,
    required this.localidade,
    required this.responsavel,
    required this.status,
    required this.dataEntrada,
    required this.dataAquisicao,
    required this.valor,
    required this.fornecedor,
    required this.vidaUtilMeses,
    required this.ultimaMovimentacaoEm,
    required this.ultimaMovimentacaoPor,
    required this.versao,
    required this.criadoEm,
    required this.atualizadoEm,
    this.isKit = false,
    this.kit,
    this.items = const [],
  });

  bool get isBaixado => status == ActiveStatus.baixado;

  /// Item associado a um Kit: não se movimenta nem se baixa sozinho.
  bool get isKitItem => kit != null;

  /// Itens no mesmo Status do Kit: acompanham as movimentações.
  List<ActiveSummaryModel> get itemsSameStatus =>
      items.where((e) => e.status == status).toList();

  /// Itens em Status diferente do Kit: não acompanham as movimentações.
  List<ActiveSummaryModel> get itemsDifferentStatus =>
      items.where((e) => e.status != status).toList();

  factory ActiveModel.fromJson(Map<String, dynamic> json) {
    return ActiveModel(
      id: json['id'] as String,
      codigoInterno: json['codigoInterno'] as String,
      nome: json['nome'] as String,
      codigoSap: json['codigoSap'] as String?,
      numeroSerie: json['numeroSerie'] as String?,
      patrimonio: json['patrimonio'] as String?,
      tipoAtivo: RefModel.fromJson(json['tipoAtivo']),
      categoria: json['categoria'] != null
          ? RefModel.fromJson(json['categoria'])
          : null,
      subcategoria: json['subcategoria'] != null
          ? RefModel.fromJson(json['subcategoria'])
          : null,
      marca: json['marca'] as String?,
      modelo: json['modelo'] as String?,
      setor: RefModel.fromJson(json['setor']),
      localidade: RefModel.fromJson(json['localidade']),
      responsavel: json['responsavel'] as String?,
      status: ActiveStatus.fromValue(json['status'] as String),
      dataEntrada: json['dataEntrada'] as String,
      dataAquisicao: json['dataAquisicao'] as String?,
      valor: json['valor'] as String?,
      fornecedor: json['fornecedor'] != null
          ? RefModel.fromJson(json['fornecedor'])
          : null,
      vidaUtilMeses: json['vidaUtilMeses'] as int?,
      ultimaMovimentacaoEm: DateTime.parse(
        json['ultimaMovimentacaoEm'] as String,
      ),
      ultimaMovimentacaoPor: RefModel.fromJson(json['ultimaMovimentacaoPor']),
      versao: json['versao'] as int,
      criadoEm: DateTime.parse(json['criadoEm'] as String),
      atualizadoEm: DateTime.parse(json['atualizadoEm'] as String),
      isKit: json['ehKit'] as bool? ?? false,
      kit: json['kit'] != null ? KitRefModel.fromJson(json['kit']) : null,
      items: ((json['itens'] as List?) ?? const [])
          .map((e) => ActiveSummaryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
