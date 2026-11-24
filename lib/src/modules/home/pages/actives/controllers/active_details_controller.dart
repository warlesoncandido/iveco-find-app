import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:iveco_find/src/core/services/i_local_storage.dart';
import 'package:iveco_find/src/shared/enums/local_storage_keys.dart';
import 'package:iveco_find/src/shared/enums/permission.dart';
import 'package:iveco_find/src/shared/enums/movement_type.dart';
import 'package:iveco_find/src/shared/models/active_history_model.dart';
import 'package:iveco_find/src/shared/models/active_model.dart';
import 'package:iveco_find/src/shared/models/active_summary_model.dart';
import 'package:iveco_find/src/shared/models/auth_model.dart';
import 'package:iveco_find/src/shared/models/valid_movement_model.dart';
import 'package:iveco_find/src/shared/repositories/active_repository.dart';
import 'package:iveco_find/src/shared/repositories/types_repository.dart';
import 'package:iveco_find/src/shared/utils/behaviour_page.dart';

class ActiveDetailsController extends ChangeNotifier {
  final ActiveRepository repository;
  final LocalStorage storage;
  final TypesRepository typesRepository;

  ActiveDetailsController({
    required this.repository,
    required this.storage,
    required this.typesRepository,
  });

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

  /// Item de Kit não se movimenta nem se baixa sozinho (a API já devolve a
  /// lista vazia; a checagem aqui só reforça).
  bool get _isKitItem => active?.isKitItem ?? false;

  bool get canMove => !_isKitItem && commonMovements.isNotEmpty;

  bool get canWriteOff =>
      !_isKitItem && movements.any((e) => e.tipo == MovementType.baixa);

  bool get hasMoreHistory => history.length < historyTotal;

  /// Adicionar e remover itens: Kit não Baixado e Perfil com `ativos:escrever`.
  bool get canManageKitItems =>
      Permission.forProfile(perfil).contains(Permission.ativosEscrever) &&
      active != null &&
      active!.isKit &&
      !active!.isBaixado;

  /// Maior `tamanhoPagina` aceito por `GET /ativos` (`BuscaAtivosQuery` da API).
  static const maxSearchPageSize = 100;

  /// Ids dos Tipos marcados como Kit: lidos uma vez por ficha, não a cada busca.
  Set<String>? _kitTypeIds;

  Future<Set<String>> _loadKitTypeIds() async {
    final cached = _kitTypeIds;
    if (cached != null) return cached;
    final types = await typesRepository.getSelectableTypes();
    return types.fold(
      (l) => <String>{},
      (r) => _kitTypeIds = r.where((e) => e.kit).map((e) => e.id).toSet(),
    );
  }

  /// Candidatos a item: mesmo Status do Kit, sem Tipo Kit, fora o próprio Kit e
  /// seus itens. A API ainda recusa (422) item que já está em outro Kit.
  Future<List<ActiveSummaryModel>> searchKitCandidates(String query) async {
    final kit = active;
    if (kit == null) return [];
    final kitTypes = await _loadKitTypeIds();
    final result = await repository.getActives(
      page: 1,
      query: query,
      status: kit.status.value,
      pageSize: maxSearchPageSize,
    );
    final current = kit.items.map((e) => e.id).toSet();
    return result.fold(
      (l) => [],
      (r) => r.items
          .cast<ActiveSummaryModel>()
          .where(
            (e) =>
                e.id != kit.id &&
                !current.contains(e.id) &&
                !kitTypes.contains(e.tipoAtivo.id),
          )
          .toList(),
    );
  }

  Future<void> addKitItem(
    ActiveSummaryModel item, {
    required Function() onSuccess,
    required Function(String message) onError,
  }) async {
    final result = await repository.addKitItem(
      kitId: activeId,
      itemId: item.id,
      itemVersion: item.versao,
    );
    await result.fold(
      (l) async => onError(l.message ?? ''),
      (r) => _applyKit(r, onSuccess),
    );
  }

  Future<void> removeKitItem(
    ActiveSummaryModel item, {
    required Function() onSuccess,
    required Function(String message) onError,
  }) async {
    final result = await repository.removeKitItem(
      kitId: activeId,
      itemId: item.id,
      itemVersion: item.versao,
    );
    await result.fold(
      (l) async => onError(l.message ?? ''),
      (r) => _applyKit(r, onSuccess),
    );
  }

  /// A resposta é a ficha do Kit; as Movimentações válidas mudam (Baixa só sem itens).
  Future<void> _applyKit(ActiveModel kit, Function() onSuccess) async {
    active = kit;
    final movementsResult = await repository.getValidMovements(activeId);
    movements = movementsResult.getOrElse(() => movements);
    notifyListeners();
    onSuccess();
  }

  Future<void> init(String id) async {
    activeId = id;
    active = null;
    _kitTypeIds = null;
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
