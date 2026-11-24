class TypeParams {
  String name;
  String prefix;

  /// "É Kit": Ativos deste Tipo aceitam itens associados.
  bool kit;
  bool? active;

  TypeParams({
    required this.name,
    required this.prefix,
    this.kit = false,
    this.active,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data.addAll({'nome': name, 'prefixo': prefix, 'kit': kit});
    if (active != null) {
      data.addAll({'ativo': active});
    }
    return data;
  }
}
