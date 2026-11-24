import 'dart:async';

import 'package:flutter/material.dart';
import 'package:iveco_find/src/shared/models/pagination_model.dart';
import 'package:iveco_find/src/shared/models/supplier_model.dart';
import 'package:iveco_find/src/shared/repositories/supplier_repository.dart';
import 'package:iveco_find/src/shared/utils/behaviour_page.dart';

class SupplierController extends ChangeNotifier {
  final SupplierRepository repository;

  SupplierController({required this.repository});

  Behaviour behaviourPage = Behaviour.loading;

  PaginationModel? pagination;

  /// Termo da busca (razão social ou CNPJ), enviado como `q`.
  String query = '';

  Timer? _debounce;

  /// Descarta respostas de cargas mais antigas que chegam fora de ordem.
  int _seq = 0;

  List<SupplierModel> get suppliers {
    if (pagination != null) {
      return pagination!.items as List<SupplierModel>;
    }
    return [];
  }

  int currentPage = 1;

  void setCurrentPage(int value) {
    currentPage = value;
    loadSuppliers();
  }

  void search(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (value.trim() == query.trim()) return;
      query = value;
      currentPage = 1;
      loadSuppliers();
    });
  }

  Future<void> loadSuppliers() async {
    final seq = ++_seq;
    behaviourPage = Behaviour.loading;
    notifyListeners();
    final result = await repository.getSuppliers(
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
