import 'dart:async';

import 'package:flutter/material.dart';
import 'package:iveco_find/src/shared/models/pagination_model.dart';
import 'package:iveco_find/src/shared/models/type_model.dart';
import 'package:iveco_find/src/shared/repositories/types_repository.dart';
import 'package:iveco_find/src/shared/utils/behaviour_page.dart';

class TypesController extends ChangeNotifier {
  final TypesRepository typesRepository;

  TypesController({required this.typesRepository});

  PaginationModel? pagination;

  int currentPage = 1;

  /// Termo da busca (nome ou Prefixo), enviado como `q`.
  String query = '';

  Behaviour behaviourPage = Behaviour.loading;

  Timer? _debounce;

  /// Descarta respostas de cargas mais antigas que chegam fora de ordem.
  int _seq = 0;

  void setCurrentPage(int page) {
    currentPage = page;
    loadTypes();
  }

  void search(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (value.trim() == query.trim()) return;
      query = value;
      currentPage = 1;
      loadTypes();
    });
  }

  List<TypeModel> get types {
    if (pagination != null) {
      return pagination!.items as List<TypeModel>;
    }
    return [];
  }

  Future<void> loadTypes() async {
    final seq = ++_seq;
    behaviourPage = Behaviour.loading;
    notifyListeners();
    final result = await typesRepository.getTypes(
      page: currentPage,
      query: query,
    );
    if (seq != _seq) return;
    result.fold(
      (l) {
        behaviourPage = Behaviour.error;
        notifyListeners();
      },
      (r) {
        pagination = r;
        behaviourPage = Behaviour.success;
        notifyListeners();
      },
    );
  }
}
