import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:iveco_find/src/shared/models/location_model.dart';
import 'package:iveco_find/src/shared/params/location_params.dart';
import 'package:iveco_find/src/shared/repositories/location_repository.dart';
import 'package:iveco_find/src/shared/utils/behaviour_page.dart';
import 'package:iveco_find/src/shared/utils/failure.dart';

class AddOrEditLocationController extends ChangeNotifier {
  final LocationRepository repository;
  AddOrEditLocationController({required this.repository});

  LocationModel? location;

  bool active = false;

  final nameController = TextEditingController();

  Behaviour? behaviour;

  final formKey = GlobalKey<FormState>();

  void fillFields(LocationModel? value) {
    if (value != null) {
      location = value;
      nameController.text = value.nome;
      active = value.ativo;
      notifyListeners();
    }
  }

  void changeActive(bool value) {
    active = value;
    notifyListeners();
  }

  Future<void> saveLocation({
    required Function() onSuccess,
    required Function(String message) onError,
  }) async {
    behaviour = Behaviour.loading;
    notifyListeners();
    final params = LocationParams(name: nameController.text);
    Either<Failure, bool> result;
    if (location != null) {
      params.active = active;
      result = await repository.updateLocation(params, location!.id);
    } else {
      result = await repository.saveLocation(params);
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
    location = null;
    active = false;
  }
}
