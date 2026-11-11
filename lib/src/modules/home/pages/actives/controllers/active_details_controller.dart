import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:iveco_find/src/core/services/i_local_storage.dart';
import 'package:iveco_find/src/shared/enums/local_storage_keys.dart';
import 'package:iveco_find/src/shared/enums/permission.dart';
import 'package:iveco_find/src/shared/enums/movement_type.dart';
import 'package:iveco_find/src/shared/models/active_history_model.dart';
import 'package:iveco_find/src/shared/models/active_model.dart';
import 'package:iveco_find/src/shared/models/auth_model.dart';
import 'package:iveco_find/src/shared/models/valid_movement_model.dart';
import 'package:iveco_find/src/shared/repositories/active_repository.dart';
import 'package:iveco_find/src/shared/utils/behaviour_page.dart';

class ActiveDetailsController extends ChangeNotifier {
  final ActiveRepository repository;
  final LocalStorage storage;

  ActiveDetailsController({required this.repository, required this.storage});

  late String activeId;

  ActiveModel? active;

  Behaviour behaviourPage = Behaviour.loading;

  List<ValidMovementModel> movements = [];

  List<ActiveHistoryModel> history = [];
  int historyTotal = 0;
  int historyPage = 1;
  bool loadingHistory = false;

  String? perfil;

  /// Alterar exige `ativos:escrever`; Baixado é terminal e não aceita alteração.
  bool get canEdit =>
      Permission.forProfile(perfil).contains(Permission.ativosEscrever) &&
      active != null &&
      !active!.isBaixado;

  /// A API já filtra pelo Status atual e pelo Perfil.
  List<ValidMovementModel> get commonMovements =>
      movements.where((e) => e.tipo != MovementType.baixa).toList();

  bool get canMove => commonMovements.isNotEmpty;

  bool get canWriteOff => movements.any((e) => e.tipo == MovementType.baixa);

  bool get hasMoreHistory => history.length < historyTotal;

  Future<void> init(String id) async {
    activeId = id;
    active = null;
    movements = [];
    history = [];
    await _loadPerfil();
    await load();
  }

  Future<void> _loadPerfil() async {
    final auth = await storage.getString(LocalStorageKeys.auth.name());
    if (auth != null && auth.isNotEmpty) {
      perfil = AuthModel.fromJson(json.decode(auth)).user.perfil;
    }
  }

  Future<void> load() async {
    behaviourPage = Behaviour.loading;
    notifyListeners();

    final result = await repository.getActive(activeId);
    active = result.fold((l) => null, (r) => r);
    if (active == null) {
      behaviourPage = Behaviour.error;
      notifyListeners();
      return;
    }

    final movementsResult = await repository.getValidMovements(activeId);
    movements = movementsResult.getOrElse(() => []);

    historyPage = 1;
    history = [];
    await _loadHistory();

    behaviourPage = Behaviour.success;
    notifyListeners();
  }

  Future<void> loadMoreHistory() async {
    historyPage++;
    loadingHistory = true;
    notifyListeners();
    await _loadHistory();
    loadingHistory = false;
    notifyListeners();
  }

  Future<void> _loadHistory() async {
    final result = await repository.getHistory(id: activeId, page: historyPage);
    result.fold((l) {}, (r) {
      historyTotal = r.total;
      history = [...history, ...r.items.cast<ActiveHistoryModel>()];
    });
  }
}
