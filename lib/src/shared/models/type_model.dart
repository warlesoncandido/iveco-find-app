class TypeModel {
  final String id;
  final String nome;
  final String prefixo;
  final bool ativo;
  final DateTime criadoEm;
  final DateTime atualizadoEm;

  TypeModel({
    required this.id,
    required this.nome,
    required this.prefixo,
    required this.ativo,
    required this.criadoEm,
    required this.atualizadoEm,
  });

  factory TypeModel.fromJson(Map<String, dynamic> json) {
    return TypeModel(
      id: json['id'] as String,
      nome: json['nome'] as String,
      prefixo: json['prefixo'] as String,
      ativo: json['ativo'] as bool,
      criadoEm: DateTime.parse(json['criadoEm'] as String),
      atualizadoEm: DateTime.parse(json['atualizadoEm'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'prefixo': prefixo,
      'ativo': ativo,
      'criadoEm': criadoEm.toIso8601String(),
      'atualizadoEm': atualizadoEm.toIso8601String(),
    };
  }
}
