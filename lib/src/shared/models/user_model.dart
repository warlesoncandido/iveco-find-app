class UserModel {
  final String id;
  final String nome;
  final String email;
  final String perfil;

  UserModel({
    required this.id,
    required this.nome,
    required this.email,
    required this.perfil,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      nome: json['nome'],
      email: json['email'],
      perfil: json['perfil'],
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data.addAll({'id': id, 'nome': nome, 'email': email, 'perfil': perfil});
    return data;
  }
}
