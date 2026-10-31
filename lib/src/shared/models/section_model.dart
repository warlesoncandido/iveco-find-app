class SectionModel {
  final String id;
  final String nome;
  final bool ativo;
  final DateTime criadoEm;
  final DateTime atualizadoEm;

  SectionModel({
    required this.id,
    required this.nome,
    required this.ativo,
    required this.criadoEm,
    required this.atualizadoEm,
  });

  factory SectionModel.fromJson(Map<String, dynamic> json) {
    return SectionModel(
      id: json['id'] as String,
      nome: json['nome'] as String,
      ativo: json['ativo'] as bool,
      criadoEm: DateTime.parse(json['criadoEm'] as String),
      atualizadoEm: DateTime.parse(json['atualizadoEm'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'ativo': ativo,
      'criadoEm': criadoEm.toIso8601String(),
      'atualizadoEm': atualizadoEm.toIso8601String(),
    };
  }
}
