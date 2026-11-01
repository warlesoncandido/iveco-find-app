import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:iveco_find/src/shared/models/section_model.dart';
import 'package:iveco_find/src/shared/params/section_params.dart';
import 'package:iveco_find/src/shared/repositories/section_repository.dart';
import 'package:iveco_find/src/shared/utils/behaviour_page.dart';
import 'package:iveco_find/src/shared/utils/failure.dart';

class AddOrEditSectionController extends ChangeNotifier {
  final SectionRepository repository;
  AddOrEditSectionController({required this.repository});

  late String locationId;

  SectionModel? section;

  bool active = false;

  final nameController = TextEditingController();

  Behaviour? behaviour;

  final formKey = GlobalKey<FormState>();

  void fillFields(String locationId, SectionModel? value) {
    this.locationId = locationId;
    if (value != null) {
      section = value;
      nameController.text = value.nome;
      active = value.ativo;
      notifyListeners();
    }
  }

  void changeActive(bool value) {
    active = value;
    notifyListeners();
  }

  Future<void> saveSection({
    required Function() onSuccess,
    required Function(String message) onError,
  }) async {
    behaviour = Behaviour.loading;
    notifyListeners();
    final params = SectionParams(name: nameController.text);
    Either<Failure, bool> result;
    if (section != null) {
      params.active = active;
      result = await repository.updateSection(params, locationId, section!.id);
    } else {
      result = await repository.saveSection(params, locationId);
    }

    result.fold(
      (l) {
        onError(l.message!);
      },
      (r) {
        onSuccess();
      },
    );

    behaviour = null;
    notifyListeners();
  }

  void clearFields() {
    nameController.clear();
    section = null;
    active = false;
  }
}
