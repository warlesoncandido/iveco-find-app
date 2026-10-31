import 'package:flutter/material.dart';
import 'package:iveco_find/src/shared/models/location_model.dart';
import 'package:iveco_find/src/shared/models/pagination_model.dart';
import 'package:iveco_find/src/shared/models/section_model.dart';
import 'package:iveco_find/src/shared/repositories/section_repository.dart';
import 'package:iveco_find/src/shared/utils/behaviour_page.dart';

class LocationDetailsController extends ChangeNotifier {
  final SectionRepository repository;

  LocationDetailsController({required this.repository});

  late LocationModel location;

  Behaviour behaviourPage = Behaviour.loading;

  PaginationModel? pagination;

  List<SectionModel> get sections {
    if (pagination != null) {
      return pagination!.items as List<SectionModel>;
    }
    return [];
  }

  int currentPage = 1;

  void init(LocationModel value) {
    location = value;
    pagination = null;
    currentPage = 1;
    loadSections();
  }

  void setCurrentPage(int page) {
    currentPage = page;
    loadSections();
  }

  Future<void> loadSections() async {
    behaviourPage = Behaviour.loading;
    notifyListeners();
    final result = await repository.getAllSectionByLocation(
      locationId: location.id,
      page: currentPage,
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
