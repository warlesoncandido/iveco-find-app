/// Item de `GET /api/v1/dashboard/ativos-por-localidade`.
class LocationCountModel {
  final String id;
  final String nome;
  final int quantidade;

  LocationCountModel({
    required this.id,
    required this.nome,
    required this.quantidade,
  });

  factory LocationCountModel.fromJson(Map<String, dynamic> json) {
    final localidade = json['localidade'] as Map<String, dynamic>;
    return LocationCountModel(
      id: localidade['id'] as String,
      nome: localidade['nome'] as String,
      quantidade: json['quantidade'] as int,
    );
  }
}
