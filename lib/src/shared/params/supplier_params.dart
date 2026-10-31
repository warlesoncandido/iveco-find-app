class SupplierParams {
  String name;
  String cnpj;
  String phone;

  bool? active;

  SupplierParams({
    required this.name,
    required this.cnpj,
    required this.phone,
    this.active,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data.addAll({'razaoSocial': name, 'cnpj': cnpj, 'contato': phone});
    if (active != null) {
      data.addAll({'ativo': active});
    }
    return data;
  }
}
