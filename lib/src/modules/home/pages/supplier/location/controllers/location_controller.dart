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

  Future<void> loadLocations() async {
    behaviourPage = Behaviour.loading;
    notifyListeners();
    final result = await repository.getAllLocations(page: currentPage);

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
