class SectionParams {
  String name;
  bool? active;

  SectionParams({required this.name, this.active});

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data.addAll({'nome': name});
    if (active != null) {
      data.addAll({'ativo': active});
    }
    return data;
  }
}
