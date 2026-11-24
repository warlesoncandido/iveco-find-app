import 'package:flutter/material.dart';
import 'package:iveco_find/src/core/l10n/locale_controller.dart';
import 'package:iveco_find/src/shared/enums/movement_type.dart';
import 'package:iveco_find/src/shared/models/active_model.dart';
import 'package:iveco_find/src/shared/models/active_summary_model.dart';
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

  /// Kit: itens que acompanham a movimentação (mesmo Status do Kit). Na
  /// Transferência, quem já está no Setor de destino não tem o que mudar e fica.
  List<ActiveSummaryModel> get followingItems => active.items.where((item) {
    if (item.status != active.status) return false;
    if (sectionRequired && section != null && item.setor.id == section!.id) {
      return false;
    }
    return true;
  }).toList();

  /// Kit: itens que não acompanham a movimentação (Status diferente do Kit).
  /// Na Transferência, quem já está no Setor de destino não entra aqui: não
  /// muda, mas fica onde o Kit foi.
  List<ActiveSummaryModel> get leftBehindItems =>
      active.items.where((e) => e.status != active.status).toList();

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
      return L10n.current.moveSelectSection;
    }
    if (sectionRequired && value?.id == active.setor.id) {
      return L10n.current.moveSelectDifferentSection;
    }
    return null;
  }

  /// `onSuccess` recebe quantos itens do Kit ficaram para trás (0 fora de Kit).
  Future<void> save({
    required Function(int leftBehind) onSuccess,
    required Function(String message) onError,
  }) async {
    behaviour = Behaviour.loading;
    notifyListeners();
    final leftBehind = leftBehindItems.length;

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

    result.fold((l) => onError(l.message!), (r) => onSuccess(leftBehind));
  }
}
