class ActiveParams {
  String name;
  String? sapCode;
  String? serialNumber;
  String? patrimony;
  String typeId;
  String? categoryId;
  String? brand;
  String? model;
  String? sectionId;
  String? responsible;
  String entryDate;
  String? acquisitionDate;
  String? value;
  String? supplierId;
  int? usefulLifeMonths;
  int? version;

  ActiveParams({
    required this.name,
    this.sapCode,
    this.serialNumber,
    this.patrimony,
    required this.typeId,
    this.categoryId,
    this.brand,
    this.model,
    this.sectionId,
    this.responsible,
    required this.entryDate,
    this.acquisitionDate,
    this.value,
    this.supplierId,
    this.usefulLifeMonths,
    this.version,
  });

  /// No cadastro vão o Setor e a Categoria; na alteração vai a versão (o Setor
  /// só muda por Movimentação e a Categoria, fora do app por enquanto, não muda).
  /// Opcionais vazios vão como `null`, que na alteração limpa o campo.
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'nome': name,
      'codigoSap': sapCode,
      'numeroSerie': serialNumber,
      'patrimonio': patrimony,
      'tipoAtivoId': typeId,
      'marca': brand,
      'modelo': model,
      'responsavel': responsible,
      'dataEntrada': entryDate,
      'dataAquisicao': acquisitionDate,
      'valor': value,
      'fornecedorId': supplierId,
      'vidaUtilMeses': usefulLifeMonths,
    };
    if (version != null) {
      data.addAll({'versao': version});
    } else {
      data.addAll({'setorId': sectionId, 'categoriaId': categoryId});
    }
    return data;
  }
}
