import 'package:flutter/material.dart';
import 'package:iveco_find/src/shared/models/pagination_model.dart';
import 'package:iveco_find/src/shared/repositories/supplier_repository.dart';
import 'package:iveco_find/src/shared/utils/behaviour_page.dart';

class SupplierController extends ChangeNotifier {
  final SupplierRepository repository;

  SupplierController({required this.repository});

  Behaviour behaviourpage = Behaviour.loading;

  PaginationModel? pagination;

  int currentPage = 1;

  void setCurrentPage(int value) {
    currentPage = value;
    notifyListeners();
  }

  Future<void> loadSuppliers() async {
    behaviourpage = Behaviour.loading;
    notifyListeners();
    await Future.delayed(Duration(seconds: 3));
    pagination = PaginationModel(total: 12, page: 1, maxPerPage: 25, items: []);

    behaviourpage = Behaviour.success;
    notifyListeners();
  }
}
