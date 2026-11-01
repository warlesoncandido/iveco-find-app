import 'package:flutter/material.dart';
import 'package:iveco_find/src/shared/enums/movement_type.dart';
import 'package:iveco_find/src/shared/models/active_model.dart';
import 'package:iveco_find/src/shared/models/ref_model.dart';
import 'package:iveco_find/src/shared/models/valid_movement_model.dart';
import 'package:iveco_find/src/shared/params/movement_params.dart';
import 'package:iveco_find/src/shared/repositories/active_repository.dart';
import 'package:iveco_find/src/shared/repositories/location_repository.dart';
import 'package:iveco_find/src/shared/repositories/section_repository.dart';
import 'package:iveco_find/src/shared/utils/behaviour_page.dart';

class MoveActiveController extends ChangeNotifier {
  final ActiveRepository repository;
  final LocationRepository locationRepository;
  final SectionRepository sectionRepository;

  MoveActiveController({
    required this.repository,
    required this.locationRepository,
    required this.sectionRepository,
  });

  late ActiveModel active;

  List<ValidMovementModel> movements = [];
  ValidMovementModel? movement;

  List<RefModel> locations = [];
  List<RefModel> sections = [];
  RefModel? location;
  RefModel? section;

  Behaviour? behaviour;

  final formKey = GlobalKey<FormState>();
  final responsibleController = TextEditingController();
  final observationController = TextEditingController();

  bool get showSection =>
      movement != null && movement!.setor != SectionRule.proibido;

  bool get sectionRequired => movement?.setor == SectionRule.obrigatorio;

  Future<void> init(ActiveModel value, List<ValidMovementModel> valid) async {
    active = value;
    movements = valid;
    movement = valid.length == 1 ? valid.first : null;
    responsibleController.text = value.responsavel ?? '';
    observationController.clear();
    location = value.localidade;
    section = null;
    sections = [];
    notifyListeners();

    final result = await locationRepository.getSelectableLocations();
    locations = result
        .getOrElse(() => [])
        .map((e) => RefModel(id: e.id, nome: e.nome, ativo: e.ativo))
        .toList();
    await changeLocation(location);
  }

  void changeMovement(ValidMovementModel? value) {
    movement = value;
    notifyListeners();
  }

  Future<void> changeLocation(RefModel? value) async {
    location = value;
    section = null;
    sections = [];
    notifyListeners();
    if (value != null) {
      final result = await sectionRepository.getSelectableSections(value.id);
      sections = result
          .getOrElse(() => [])
          .map((e) => RefModel(id: e.id, nome: e.nome, ativo: e.ativo))
          .toList();
      notifyListeners();
    }
  }

  void changeSection(RefModel? value) {
    section = value;
    notifyListeners();
  }

  String? validateSection(RefModel? value) {
    if (sectionRequired && value == null) {
      return 'Selecione o setor de destino.';
    }
    if (sectionRequired && value?.id == active.setor.id) {
      return 'Selecione um setor diferente do atual.';
    }
    return null;
  }

  Future<void> save({
    required Function() onSuccess,
    required Function(String message) onError,
  }) async {
    behaviour = Behaviour.loading;
    notifyListeners();

    // Responsável só vai se mudou; vazio limpa o campo.
    final responsible = responsibleController.text.trim();
    final observation = observationController.text.trim();
    final params = MovementParams(
      version: active.versao,
      type: movement!.tipo.value,
      sectionId: showSection ? section?.id : null,
      responsible: responsible != (active.responsavel ?? '')
          ? responsible
          : null,
      observation: observation.isEmpty ? null : observation,
    );

    final result = await repository.moveActive(params, active.id);

    behaviour = null;
    notifyListeners();

    result.fold((l) => onError(l.message!), (r) => onSuccess());
  }
}
