import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iveco_find/src/modules/public/public_active_model.dart';
import 'package:iveco_find/src/modules/public/public_active_page.dart';
import 'package:iveco_find/src/modules/public/public_active_repository.dart';
import 'package:iveco_find/src/shared/utils/failure.dart';

class FakePublicActiveRepository extends PublicActiveRepository {
  FakePublicActiveRepository(this.responses);

  /// Uma resposta por chamada, em ordem; a última se repete.
  final List<Either<Failure, PublicActive>> responses;
  final calls = <String>[];

  @override
  Future<Either<Failure, PublicActive>> fetch(String id) async {
    calls.add(id);
    final index = calls.length - 1;
    return responses[index < responses.length ? index : responses.length - 1];
  }
}

const _active = PublicActive(
  nome: 'Furadeira',
  codigoInterno: 'FER-000123',
  localidade: 'Sete Lagoas',
  status: 'EM_MANUTENCAO',
);

final _notFound = Left<Failure, PublicActive>(
  Failure(message: 'Ativo não encontrado', code: PublicActiveRepository.notFound),
);
final _networkError = Left<Failure, PublicActive>(Failure(message: 'Não foi possível carregar o ativo.'));

Future<void> _pump(WidgetTester tester, String? id, FakePublicActiveRepository repo) {
  return tester.pumpWidget(MaterialApp(home: PublicActivePage(id: id, repository: repo)));
}

void main() {
  testWidgets('mostra carregando e depois o card com os 4 campos e a tag de status', (tester) async {
    final repo = FakePublicActiveRepository([const Right(_active)]);
    await _pump(tester, 'abc', repo);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();
    expect(repo.calls, ['abc']);
    expect(find.text('Furadeira'), findsOneWidget);
    expect(find.text('FER-000123'), findsOneWidget);
    expect(find.text('Sete Lagoas'), findsOneWidget);
    expect(find.text('Em manutenção'), findsOneWidget);
  });

  testWidgets('status desconhecido aparece como texto bruto', (tester) async {
    final repo = FakePublicActiveRepository([
      const Right(PublicActive(nome: 'X', codigoInterno: 'Y', localidade: 'Z', status: 'NOVO_STATUS')),
    ]);
    await _pump(tester, 'abc', repo);
    await tester.pumpAndSettle();
    expect(find.text('NOVO_STATUS'), findsOneWidget);
  });

  testWidgets('404: "Ativo não encontrado" sem botão de tentar novamente', (tester) async {
    final repo = FakePublicActiveRepository([_notFound]);
    await _pump(tester, 'abc', repo);
    await tester.pumpAndSettle();
    expect(find.text('Ativo não encontrado'), findsOneWidget);
    expect(find.text('Tentar novamente'), findsNothing);
  });

  testWidgets('sem id: "Ativo não encontrado" sem chamar a API', (tester) async {
    final repo = FakePublicActiveRepository([const Right(_active)]);
    await _pump(tester, null, repo);
    await tester.pumpAndSettle();
    expect(find.text('Ativo não encontrado'), findsOneWidget);
    expect(repo.calls, isEmpty);
  });

  testWidgets('falha de rede: erro e "Tentar novamente" refaz a chamada', (tester) async {
    final repo = FakePublicActiveRepository([_networkError, const Right(_active)]);
    await _pump(tester, 'abc', repo);
    await tester.pumpAndSettle();
    expect(find.text('Não foi possível carregar o ativo.'), findsOneWidget);
    expect(find.text('Tentar novamente'), findsOneWidget);

    await tester.tap(find.text('Tentar novamente'));
    await tester.pumpAndSettle();
    expect(repo.calls, ['abc', 'abc']);
    expect(find.text('Furadeira'), findsOneWidget);
    expect(find.text('Tentar novamente'), findsNothing);
  });
}
