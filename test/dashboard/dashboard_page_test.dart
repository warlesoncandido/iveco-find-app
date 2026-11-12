import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iveco_find/src/modules/home/pages/dashboard/components/bar_list_component.dart';
import 'package:iveco_find/src/modules/home/pages/dashboard/controllers/dashboard_controller.dart';
import 'package:iveco_find/src/modules/home/pages/dashboard/pages/dashboard_page.dart';
import 'package:iveco_find/src/shared/utils/failure.dart';

import 'fakes.dart';

Future<void> _pump(
  WidgetTester tester,
  FakeDashboardRepository repo, {
  Size size = const Size(400, 900),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      home: DashboardPage(controller: DashboardController(repository: repo)),
    ),
  );
}

/// "R$ 1.234,50" pode vir com espaço não separável.
Finder _textMatching(String pattern) => find.byWidgetPredicate(
  (w) => w is Text && RegExp(pattern).hasMatch(w.data ?? ''),
);

void main() {
  for (final entry in {
    'celular': const Size(400, 1600),
    'desktop': const Size(1400, 1000),
  }.entries) {
    testWidgets('renderiza cards e barras com dados (${entry.key})', (
      tester,
    ) async {
      final repo = FakeDashboardRepository();
      await _pump(tester, repo, size: entry.value);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Total de ativos'), findsOneWidget);
      expect(find.text('6'), findsOneWidget);
      expect(find.text('Em uso'), findsWidgets); // card + barra de Status
      expect(find.text('50% do total'), findsOneWidget);
      expect(_textMatching(r'^R\$\s1\.234,50$'), findsOneWidget);
      expect(find.text('1 sem valor'), findsOneWidget);

      expect(find.text('Por status'), findsOneWidget);
      expect(find.text('Disponível'), findsOneWidget);
      expect(find.text('Em manutenção'), findsOneWidget);
      expect(find.text('Baixado'), findsOneWidget);
      expect(find.text('Por localidade'), findsOneWidget);
      expect(find.text('Top 5 por tipo'), findsOneWidget);
      expect(find.text('Furadeira'), findsOneWidget);
      expect(find.text('Notebook'), findsOneWidget);
      expect(find.text(BarListComponent.emptyText), findsNothing);

      // Localidades por quantidade desc: Sete Lagoas (4) antes de Betim (2).
      final sete = tester.getTopLeft(find.text('Sete Lagoas'));
      final betim = tester.getTopLeft(find.text('Betim'));
      expect(sete.dy, lessThan(betim.dy));
    });
  }

  testWidgets(
    'sem Ativos: cards com 0 e "Nenhum ativo cadastrado" nos 3 blocos de barras',
    (tester) async {
      final repo = FakeDashboardRepository()
        ..summary = emptySummaryJson
        ..locations = [];
      await _pump(tester, repo, size: const Size(400, 1600));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('0'), findsNWidgets(2)); // Total e Em uso
      expect(find.text('0% do total'), findsOneWidget);
      expect(_textMatching(r'^R\$\s0,00$'), findsOneWidget);
      expect(find.text(BarListComponent.emptyText), findsNWidgets(3));
    },
  );

  testWidgets(
    'erro mostra ErrorPage e "Tentar novamente" refaz as 2 chamadas',
    (tester) async {
      final repo = FakeDashboardRepository()
        ..summaryFailure = Failure(message: 'x');
      await _pump(tester, repo);
      await tester.pumpAndSettle();

      expect(find.text('Tentar novamente'), findsOneWidget);
      expect(repo.summaryCalls, 1);
      expect(repo.locationCalls, 1);

      repo.summaryFailure = null;
      await tester.tap(find.text('Tentar novamente'));
      await tester.pumpAndSettle();

      expect(repo.summaryCalls, 2);
      expect(repo.locationCalls, 2);
      expect(find.text('Tentar novamente'), findsNothing);
      expect(find.text('Total de ativos'), findsOneWidget);
    },
  );
}
