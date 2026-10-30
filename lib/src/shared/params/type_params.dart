class TypeParams {
  String name;
  String prefix;

  TypeParams({required this.name, required this.prefix});

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data.addAll({'nome': name, 'prefixo': prefix});
    return data;
  }
}
