/// Dados públicos do Ativo (`GET /api/v1/publico/ativos/:id`): só os 4 campos do QR Code.
class PublicActive {
  final String nome;
  final String codigoInterno;
  final String localidade;

  /// Valor bruto do status (`DISPONIVEL`, `EM_USO`, `EM_MANUTENCAO`, `BAIXADO`).
  final String status;

  const PublicActive({
    required this.nome,
    required this.codigoInterno,
    required this.localidade,
    required this.status,
  });

  factory PublicActive.fromJson(Map<String, dynamic> json) {
    return PublicActive(
      nome: json['nome'] as String,
      codigoInterno: json['codigoInterno'] as String,
      localidade: json['localidade'] as String,
      status: json['status'] as String,
    );
  }
}
