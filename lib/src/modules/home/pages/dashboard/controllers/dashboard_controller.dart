import 'package:flutter/material.dart';
import 'package:iveco_find/src/shared/models/dashboard_summary_model.dart';
import 'package:iveco_find/src/shared/models/location_count_model.dart';
import 'package:iveco_find/src/shared/repositories/dashboard_repository.dart';
import 'package:iveco_find/src/shared/utils/behaviour_page.dart';

class DashboardController extends ChangeNotifier {
  final DashboardRepository repository;

  DashboardController({required this.repository});

  Behaviour behaviourPage = Behaviour.loading;

  DashboardSummaryModel? summary;

  /// Ordenadas por `quantidade` desc (empate mantém a ordem da API, por nome).
  List<LocationCountModel> locations = [];

  int _loadId = 0;

  /// Faz as 2 chamadas em paralelo; qualquer falha → `Behaviour.error`.
  Future<void> load() async {
    final id = ++_loadId;
    behaviourPage = Behaviour.loading;
    notifyListeners();

    final summaryFuture = repository.getSummary();
    final locationsFuture = repository.getByLocation();
    final summaryResult = await summaryFuture;
    final locationsResult = await locationsFuture;
    if (id != _loadId) return; // uma recarga mais nova já está em andamento

    if (summaryResult.isLeft() || locationsResult.isLeft()) {
      behaviourPage = Behaviour.error;
      notifyListeners();
      return;
    }
    summary = summaryResult.getOrElse(() => throw StateError('unreachable'));
    final list = locationsResult.getOrElse(
      () => throw StateError('unreachable'),
    );
    final indexed = list.asMap().entries.toList()
      ..sort((a, b) {
        final byCount = b.value.quantidade.compareTo(a.value.quantidade);
        return byCount != 0 ? byCount : a.key.compareTo(b.key);
      });
    locations = indexed.map((e) => e.value).toList();
    behaviourPage = Behaviour.success;
    notifyListeners();
  }
}
