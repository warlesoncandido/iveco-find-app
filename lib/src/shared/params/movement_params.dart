class MovementParams {
  int version;
  String type;
  String? sectionId;
  String? responsible;
  String? observation;

  MovementParams({
    required this.version,
    required this.type,
    this.sectionId,
    this.responsible,
    this.observation,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{'versao': version, 'tipo': type};
    if (sectionId != null) {
      data.addAll({'setorId': sectionId});
    }
    if (responsible != null) {
      data.addAll({'responsavel': responsible});
    }
    if (observation != null) {
      data.addAll({'observacao': observation});
    }
    return data;
  }
}

class WriteOffParams {
  int version;
  String observation;
  String? responsible;

  WriteOffParams({
    required this.version,
    required this.observation,
    this.responsible,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'versao': version,
      'observacao': observation,
    };
    if (responsible != null) {
      data.addAll({'responsavel': responsible});
    }
    return data;
  }
}
