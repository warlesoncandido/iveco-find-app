class UserModel {
  final String id;
  final String nome;
  final String email;
  final String perfil;

  /// Opcionais: o `auth` salvo antes deste campo existir não os tem.
  final bool ativo;
  final bool trocaSenhaObrigatoria;

  UserModel({
    required this.id,
    required this.nome,
    required this.email,
    required this.perfil,
    this.ativo = true,
    this.trocaSenhaObrigatoria = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      nome: json['nome'],
      email: json['email'],
      perfil: json['perfil'],
      ativo: json['ativo'] ?? true,
      trocaSenhaObrigatoria: json['trocaSenhaObrigatoria'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data.addAll({
      'id': id,
      'nome': nome,
      'email': email,
      'perfil': perfil,
      'ativo': ativo,
      'trocaSenhaObrigatoria': trocaSenhaObrigatoria,
    });
    return data;
  }
}
