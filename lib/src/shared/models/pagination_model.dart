class PaginationModel {
  final int total;
  final int page;
  final int maxPerPage;
  List<dynamic> items;

  PaginationModel({
    required this.total,
    required this.page,
    required this.maxPerPage,
    required this.items,
  });

  factory PaginationModel.fromJson(
    Map<String, dynamic> json, {
    required List<dynamic> list,
  }) {
    return PaginationModel(
      total: json['total'] as int,
      page: json['pagina'] as int,
      maxPerPage: json['tamanhoPagina'] as int,
      items: list,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'pagina': page,
      'tamanhoPagina': maxPerPage,
      'items': items,
    };
  }

  int get calculateTotalPages {
    return (total / 25).ceil();
  }
}
