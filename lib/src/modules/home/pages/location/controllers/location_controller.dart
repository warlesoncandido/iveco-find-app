import 'dart:async';

import 'package:flutter/material.dart';
import 'package:iveco_find/src/shared/models/location_model.dart';
import 'package:iveco_find/src/shared/models/pagination_model.dart';
import 'package:iveco_find/src/shared/repositories/location_repository.dart';
import 'package:iveco_find/src/shared/utils/behaviour_page.dart';

class LocationController extends ChangeNotifier {
  final LocationRepository repository;

  LocationController({required this.repository});

  Behaviour behaviourPage = Behaviour.loading;

  PaginationModel? pagination;

  /// Termo da busca (nome), enviado como `q`.
  String query = '';

  Timer? _debounce;

  /// Descarta respostas de cargas mais antigas que chegam fora de ordem.
  int _seq = 0;

  List<LocationModel> get locations {
    if (pagination != null) {
      return pagination!.items as List<LocationModel>;
    }
    return [];
  }

  int currentPage = 1;

  void setCurrentPage(int page) {
    currentPage = page;
    loadLocations();
  }

  void search(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (value.trim() == query.trim()) return;
      query = value;
      currentPage = 1;
      loadLocations();
    });
  }

  Future<void> loadLocations() async {
    final seq = ++_seq;
    behaviourPage = Behaviour.loading;
    notifyListeners();
    final result = await repository.getAllLocations(
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
