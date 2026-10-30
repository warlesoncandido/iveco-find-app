import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:iveco_find/src/shared/models/type_model.dart';
import 'package:iveco_find/src/shared/params/type_params.dart';
import 'package:iveco_find/src/shared/repositories/types_repository.dart';
import 'package:iveco_find/src/shared/utils/behaviour_page.dart';
import 'package:iveco_find/src/shared/utils/failure.dart';

class AddOrEditTypeController extends ChangeNotifier {
  final TypesRepository repository;
  AddOrEditTypeController({required this.repository});

  TypeModel? type;

  final nameController = TextEditingController();
  final prefixController = TextEditingController();

  Behaviour? behaviour;

  final formKey = GlobalKey<FormState>();

  void fillFields(TypeModel? value) {
    if (value != null) {
      type = value;
      nameController.text = value.nome;
      prefixController.text = value.prefixo;
      notifyListeners();
    }
  }

  Future<void> saveType({
    required Function() onSuccess,
    required Function() onError,
  }) async {
    behaviour = Behaviour.loading;
    notifyListeners();
    final params = TypeParams(
      name: nameController.text,
      prefix: prefixController.text,
    );
    Either<Failure, bool> result;
    if (type != null) {
      result = await repository.updateType(params, type!.id);
    } else {
      result = await repository.saveType(params);
    }

    result.fold(
      (l) {
        onError();
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
    prefixController.clear();
  }
}
