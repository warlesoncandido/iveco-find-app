import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iveco_find/src/modules/home/pages/actives/components/active_qr_card_component.dart';
import 'package:iveco_find/src/modules/home/pages/actives/services/active_label_printer.dart';
import 'package:qr_flutter/qr_flutter.dart';

class FakeLabelPrinter extends ActiveLabelPrinter {
  FakeLabelPrinter({this.fail = false});

  final bool fail;
  final calls = <Map<String, String>>[];

  @override
  Future<bool> printLabel({
    required String url,
    required String codigoInterno,
    required String nome,
  }) async {
    calls.add({'url': url, 'codigoInterno': codigoInterno, 'nome': nome});
    if (fail) throw Exception('impressora indisponível');
    return true;
  }
}

void main() {
  const url = 'https://find.exemplo.com/a/abc';

  Future<void> pumpCard(WidgetTester tester, FakeLabelPrinter printer) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ActiveQrCardComponent(
              id: 'abc',
              codigoInterno: 'FER-000123',
              nome: 'Furadeira',
              printer: printer,
              url: url,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('mostra o QR, o código interno e o botão de impressão', (tester) async {
    await pumpCard(tester, FakeLabelPrinter());
    expect(find.byType(QrImageView), findsOneWidget);
    expect(find.text('FER-000123'), findsOneWidget);
    expect(find.text('Imprimir etiqueta'), findsOneWidget);
  });

  testWidgets('Imprimir etiqueta chama a impressora com a URL do QR', (tester) async {
    final printer = FakeLabelPrinter();
    await pumpCard(tester, printer);
    await tester.tap(find.text('Imprimir etiqueta'));
    await tester.pumpAndSettle();
    expect(printer.calls, [
      {'url': url, 'codigoInterno': 'FER-000123', 'nome': 'Furadeira'},
    ]);
  });

  testWidgets('falha na impressão mostra snackbar de erro', (tester) async {
    await pumpCard(tester, FakeLabelPrinter(fail: true));
    await tester.tap(find.text('Imprimir etiqueta'));
    await tester.pumpAndSettle();
    expect(find.text('Não foi possível imprimir a etiqueta.'), findsOneWidget);
  });

  testWidgets('sem url injetada usa PublicUrl.ativo(id)', (tester) async {
    final printer = FakeLabelPrinter();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ActiveQrCardComponent(
              id: 'abc',
              codigoInterno: 'FER-000123',
              nome: 'Furadeira',
              printer: printer,
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Imprimir etiqueta'));
    await tester.pumpAndSettle();
    expect(printer.calls.first['url'], endsWith('/a/abc'));
  });

  test('nome longo vira reticências na etiqueta', () {
    expect(ActiveLabelPrinter.truncate('Curto'), 'Curto');
    final longo = ActiveLabelPrinter.truncate('A' * 80);
    expect(longo.length, ActiveLabelPrinter.maxNome);
    expect(longo.endsWith('...'), isTrue);
  });

  test('gera o PDF da etiqueta', () async {
    final bytes = await const ActiveLabelPrinter().buildPdf(
      url: url,
      codigoInterno: 'FER-000123',
      nome: 'Furadeira elétrica de impacto ação',
    );
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
  });
}
