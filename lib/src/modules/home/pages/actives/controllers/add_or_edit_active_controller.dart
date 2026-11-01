import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:iveco_find/src/shared/models/active_model.dart';
import 'package:iveco_find/src/shared/models/ref_model.dart';
import 'package:iveco_find/src/shared/params/active_params.dart';
import 'package:iveco_find/src/shared/repositories/active_repository.dart';
import 'package:iveco_find/src/shared/repositories/location_repository.dart';
import 'package:iveco_find/src/shared/repositories/section_repository.dart';
import 'package:iveco_find/src/shared/repositories/supplier_repository.dart';
import 'package:iveco_find/src/shared/repositories/types_repository.dart';
import 'package:iveco_find/src/shared/utils/behaviour_page.dart';
import 'package:iveco_find/src/shared/utils/failure.dart';
import 'package:iveco_find/src/shared/utils/helpers/date_helper.dart';
import 'package:iveco_find/src/shared/utils/helpers/money_helper.dart';

class AddOrEditActiveController extends ChangeNotifier {
  final ActiveRepository repository;
  final TypesRepository typesRepository;
  final LocationRepository locationRepository;
  final SectionRepository sectionRepository;
  final SupplierRepository supplierRepository;

  AddOrEditActiveController({
    required this.repository,
    required this.typesRepository,
    required this.locationRepository,
    required this.sectionRepository,
    required this.supplierRepository,
  });

  ActiveModel? active;

  Behaviour behaviourPage = Behaviour.loading;
  Behaviour? behaviour;

  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final sapCodeController = TextEditingController();
  final serialNumberController = TextEditingController();
  final patrimonyController = TextEditingController();
  final brandController = TextEditingController();
  final modelController = TextEditingController();
  final responsibleController = TextEditingController();
  final entryDateController = TextEditingController();
  final acquisitionDateController = TextEditingController();
  final valueController = TextEditingController();
  final usefulLifeController = TextEditingController();

  // Opções e seleções como RefModel: na edição, um cadastro já desativado
  // continua aparecendo como valor atual, mesmo fora da lista da API.
  List<RefModel> types = [];
  List<RefModel> locations = [];
  List<RefModel> sections = [];
  List<RefModel> suppliers = [];

  RefModel? type;
  RefModel? location;
  RefModel? section;
  RefModel? supplier;

  bool get isEditing => active != null;

  Future<void> init(ActiveModel? value) async {
    clearFields();
    active = value;
    if (value != null) {
      nameController.text = value.nome;
      sapCodeController.text = value.codigoSap ?? '';
      serialNumberController.text = value.numeroSerie ?? '';
      patrimonyController.text = value.patrimonio ?? '';
      brandController.text = value.marca ?? '';
      modelController.text = value.modelo ?? '';
      responsibleController.text = value.responsavel ?? '';
      entryDateController.text = DateHelper.toBr(value.dataEntrada);
      acquisitionDateController.text = DateHelper.toBr(
        value.dataAquisicao ?? '',
      );
      valueController.text = value.valor != null
          ? MoneyHelper.formatMoney(double.parse(value.valor!))
          : '';
      usefulLifeController.text = value.vidaUtilMeses?.toString() ?? '';
      type = value.tipoAtivo;
      location = value.localidade;
      section = value.setor;
      supplier = value.fornecedor;
    } else {
      entryDateController.text = DateHelper.todayBr();
    }
    await loadOptions();
  }

  Future<void> loadOptions() async {
    behaviourPage = Behaviour.loading;
    notifyListeners();

    final results = await Future.wait<Either<Failure, List<dynamic>>>([
      typesRepository.getSelectableTypes(),
      supplierRepository.getSelectableSuppliers(),
      if (!isEditing) locationRepository.getSelectableLocations(),
    ]);

    if (results.any((e) => e.isLeft())) {
      behaviourPage = Behaviour.error;
      notifyListeners();
      return;
    }

    // fold em vez de getOrElse: o Either real é Either<Failure, List<TypeModel>>
    // e o getOrElse exigiria um default do mesmo tipo concreto.
    final values = results
        .map((e) => e.fold((l) => <dynamic>[], (r) => r))
        .toList();
    types = _withCurrent(
      values[0].map((e) => RefModel(id: e.id, nome: e.nome, ativo: e.ativo)),
      type,
    );
    suppliers = _withCurrent(
      values[1].map(
        (e) => RefModel(id: e.id, nome: e.razaoSocial, ativo: e.ativo),
      ),
      supplier,
    );
    if (!isEditing) {
      locations = values[2]
          .map((e) => RefModel(id: e.id, nome: e.nome, ativo: e.ativo))
          .toList();
    }

    behaviourPage = Behaviour.success;
    notifyListeners();
  }

  List<RefModel> _withCurrent(Iterable<RefModel> list, RefModel? current) {
    final items = list.toList();
    if (current != null && !items.any((e) => e.id == current.id)) {
      items.insert(0, current);
    }
    return items;
  }

  void changeType(RefModel? value) {
    type = value;
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

  void changeSupplier(RefModel? value) {
    supplier = value;
    notifyListeners();
  }

  String? _text(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  Future<void> saveActive({
    required Function(ActiveModel active) onSuccess,
    required Function(String message) onError,
  }) async {
    behaviour = Behaviour.loading;
    notifyListeners();

    final acquisitionDate = _text(acquisitionDateController);
    final usefulLife = _text(usefulLifeController);
    final params = ActiveParams(
      name: nameController.text.trim(),
      sapCode: _text(sapCodeController),
      serialNumber: _text(serialNumberController),
      patrimony: _text(patrimonyController),
      typeId: type!.id,
      brand: _text(brandController),
      model: _text(modelController),
      sectionId: section?.id,
      responsible: _text(responsibleController),
      entryDate: DateHelper.formatDate(entryDateController.text),
      acquisitionDate: acquisitionDate != null
          ? DateHelper.formatDate(acquisitionDate)
          : null,
      value: MoneyHelper.toApi(valueController.text),
      supplierId: supplier?.id,
      usefulLifeMonths: usefulLife != null ? int.parse(usefulLife) : null,
      version: active?.versao,
    );

    final result = isEditing
        ? await repository.updateActive(params, active!.id)
        : await repository.saveActive(params);

    behaviour = null;
    notifyListeners();

    result.fold((l) => onError(l.message!), (r) => onSuccess(r));
  }

  void clearFields() {
    for (final controller in [
      nameController,
      sapCodeController,
      serialNumberController,
      patrimonyController,
      brandController,
      modelController,
      responsibleController,
      entryDateController,
      acquisitionDateController,
      valueController,
      usefulLifeController,
    ]) {
      controller.clear();
    }
    active = null;
    type = null;
    location = null;
    section = null;
    supplier = null;
    sections = [];
  }
}
