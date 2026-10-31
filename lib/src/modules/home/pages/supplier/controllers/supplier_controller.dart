import 'package:flutter/material.dart';
import 'package:iveco_find/src/shared/models/pagination_model.dart';
import 'package:iveco_find/src/shared/models/supplier_model.dart';
import 'package:iveco_find/src/shared/repositories/supplier_repository.dart';
import 'package:iveco_find/src/shared/utils/behaviour_page.dart';

class SupplierController extends ChangeNotifier {
  final SupplierRepository repository;

  SupplierController({required this.repository});

  Behaviour behaviourpage = Behaviour.loading;

  PaginationModel? pagination;

  List<SupplierModel> get suppliers {
    if (pagination != null) {
      return pagination!.items as List<SupplierModel>;
    }
    return [];
  }

  int currentPage = 1;

  void setCurrentPage(int value) {
    currentPage = value;
    notifyListeners();
  }

  Future<void> loadSuppliers() async {
    behaviourpage = Behaviour.loading;
    notifyListeners();
    final result = await repository.getSuppliers(page: currentPage);

    result.fold(
      (l) {
        behaviourpage = Behaviour.error;
        notifyListeners();
      },
      (r) {
        pagination = r;
        behaviourpage = Behaviour.success;
        notifyListeners();
      },
    );
  }
}
