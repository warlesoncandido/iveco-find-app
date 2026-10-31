class SupplierModel {
  final String id;
  final String razaoSocial;
  final String cnpj;
  final String contato;
  final bool ativo;
  final DateTime criadoEm;
  final DateTime atualizadoEm;

  SupplierModel({
    required this.id,
    required this.razaoSocial,
    required this.cnpj,
    required this.contato,
    required this.ativo,
    required this.criadoEm,
    required this.atualizadoEm,
  });

  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    return SupplierModel(
      id: json['id'],
      razaoSocial: json['razaoSocial'],
      cnpj: json['cnpj'],
      contato: json['contato'],
      ativo: json['ativo'],
      criadoEm: DateTime.parse(json['criadoEm']),
      atualizadoEm: DateTime.parse(json['atualizadoEm']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'razaoSocial': razaoSocial,
      'cnpj': cnpj,
      'contato': contato,
      'ativo': ativo,
      'criadoEm': criadoEm.toIso8601String(),
      'atualizadoEm': atualizadoEm.toIso8601String(),
    };
  }
}
