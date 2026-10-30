class TypeParams {
  String name;
  String prefix;
  bool? active;

  TypeParams({required this.name, required this.prefix, this.active});

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data.addAll({'nome': name, 'prefixo': prefix});
    if (active != null) {
      data.addAll({'ativo': active});
    }
    return data;
  }
}
