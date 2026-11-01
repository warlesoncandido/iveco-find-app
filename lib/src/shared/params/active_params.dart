class ActiveParams {
  String name;
  String? sapCode;
  String? serialNumber;
  String? patrimony;
  String typeId;
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

  /// No cadastro vai o Setor; na alteração vai a versão (o Setor só muda por
  /// Movimentação). A Categoria é opcional na API e fica fora do app por enquanto.
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
      data.addAll({'setorId': sectionId});
    }
    return data;
  }
}
