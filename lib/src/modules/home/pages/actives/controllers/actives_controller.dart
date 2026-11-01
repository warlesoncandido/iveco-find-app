import 'dart:async';

import 'package:flutter/material.dart';
import 'package:iveco_find/src/shared/enums/active_status.dart';
import 'package:iveco_find/src/shared/models/active_summary_model.dart';
import 'package:iveco_find/src/shared/models/pagination_model.dart';
import 'package:iveco_find/src/shared/repositories/active_repository.dart';
import 'package:iveco_find/src/shared/utils/behaviour_page.dart';

class ActivesController extends ChangeNotifier {
  final ActiveRepository repository;

  ActivesController({required this.repository});

  PaginationModel? pagination;

  int currentPage = 1;

  String query = '';

  ActiveStatus? status;

  Behaviour behaviourPage = Behaviour.loading;

  Timer? _debounce;

  List<ActiveSummaryModel> get actives {
    if (pagination != null) {
      return pagination!.items as List<ActiveSummaryModel>;
    }
    return [];
  }

  void setCurrentPage(int page) {
    currentPage = page;
    loadActives();
  }

  void search(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      query = value;
      currentPage = 1;
      loadActives();
    });
  }

  void changeStatus(ActiveStatus? value) {
    status = value;
    currentPage = 1;
    loadActives();
  }

  Future<void> loadActives() async {
    behaviourPage = Behaviour.loading;
    notifyListeners();
    final result = await repository.getActives(
      page: currentPage,
      query: query,
      status: status?.value,
    );
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
