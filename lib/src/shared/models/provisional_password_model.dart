/// Senha Provisória devolvida no cadastro (`UsuarioCriado`) e na redefinição
/// (`SenhaRedefinida`). Só aparece nessas respostas.
class ProvisionalPasswordModel {
  final String senhaProvisoria;
  final DateTime senhaProvisoriaExpiraEm;

  ProvisionalPasswordModel({
    required this.senhaProvisoria,
    required this.senhaProvisoriaExpiraEm,
  });

  factory ProvisionalPasswordModel.fromJson(Map<String, dynamic> json) {
    return ProvisionalPasswordModel(
      senhaProvisoria: json['senhaProvisoria'],
      senhaProvisoriaExpiraEm: DateTime.parse(json['senhaProvisoriaExpiraEm']),
    );
  }
}
