import 'package:flutter/material.dart';
import 'package:iveco_find/src/shared/models/active_model.dart';
import 'package:iveco_find/src/shared/params/movement_params.dart';
import 'package:iveco_find/src/shared/repositories/active_repository.dart';
import 'package:iveco_find/src/shared/utils/behaviour_page.dart';

class WriteOffActiveController extends ChangeNotifier {
  final ActiveRepository repository;

  WriteOffActiveController({required this.repository});

  late ActiveModel active;

  Behaviour? behaviour;

  final formKey = GlobalKey<FormState>();
  final responsibleController = TextEditingController();
  final observationController = TextEditingController();

  void init(ActiveModel value) {
    active = value;
    responsibleController.text = value.responsavel ?? '';
    observationController.clear();
  }

  Future<void> save({
    required Function() onSuccess,
    required Function(String message) onError,
  }) async {
    behaviour = Behaviour.loading;
    notifyListeners();

    final responsible = responsibleController.text.trim();
    final params = WriteOffParams(
      version: active.versao,
      observation: observationController.text.trim(),
      responsible: responsible != (active.responsavel ?? '')
          ? responsible
          : null,
    );

    final result = await repository.writeOffActive(params, active.id);

    behaviour = null;
    notifyListeners();

    result.fold((l) => onError(l.message!), (r) => onSuccess());
  }
}
