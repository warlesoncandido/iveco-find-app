import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:iveco_find/src/shared/models/supplier_model.dart';
import 'package:iveco_find/src/shared/params/supplier_params.dart';
import 'package:iveco_find/src/shared/repositories/supplier_repository.dart';
import 'package:iveco_find/src/shared/utils/behaviour_page.dart';
import 'package:iveco_find/src/shared/utils/failure.dart';

class AddOrEditSupplierController extends ChangeNotifier {
  final SupplierRepository repository;

  AddOrEditSupplierController({required this.repository});

  final nameController = TextEditingController();
  final cnpjController = TextEditingController();
  final phoneController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  Behaviour? behaviour;

  bool active = false;

  SupplierModel? supplier;

  void fillFields(SupplierModel? value) {
    if (value != null) {
      supplier = value;
      nameController.text = value.razaoSocial;
      cnpjController.text = value.cnpj;
      phoneController.text = value.contato;
      active = value.ativo;
      notifyListeners();
    }
  }

  void changeActive(bool value) {
    active = value;
    notifyListeners();
  }

  Future<void> saveSupplier({
    required Function() onSuccess,
    required Function(String message) onError,
  }) async {
    behaviour = Behaviour.loading;
    notifyListeners();
    final params = SupplierParams(
      name: nameController.text,
      cnpj: cnpjController.text,
      phone: phoneController.text,
    );
    Either<Failure, bool> result;
    if (supplier != null) {
      params.active = active;
      result = await repository.updateSupplier(params, supplier!.id);
    } else {
      result = await repository.saveSupplier(params);
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
    cnpjController.clear();
    phoneController.clear();

    supplier = null;
  }
}
