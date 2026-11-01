class RefModel {
  final String id;
  final String nome;
  final bool ativo;

  RefModel({required this.id, required this.nome, required this.ativo});

  factory RefModel.fromJson(Map<String, dynamic> json) {
    return RefModel(
      id: json['id'] as String,
      nome: json['nome'] as String,
      ativo: json['ativo'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'nome': nome, 'ativo': ativo};
  }
}
