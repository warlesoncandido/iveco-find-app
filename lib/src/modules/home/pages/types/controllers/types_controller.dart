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

  Behaviour behaviourPage = Behaviour.loading;

  void setCurrentPage(int page) {
    currentPage = page;
    loadTypes();
  }

  List<TypeModel> get types {
    if (pagination != null) {
      return pagination!.items as List<TypeModel>;
    }
    return [];
  }

  Future<void> loadTypes() async {
    behaviourPage = Behaviour.loading;
    notifyListeners();
    final result = await typesRepository.getTypes(page: currentPage);
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
