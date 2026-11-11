import 'package:flutter_test/flutter_test.dart';
import 'package:iveco_find/src/modules/public/public_active_page.dart';

void main() {
  const id = '3f2b8c1e-6a4d-4e2f-9b7a-1c2d3e4f5a6b';

  test('extrai o id de /a/{id}', () {
    expect(idFromPath('/a/$id'), id);
  });

  test('aceita barra final', () {
    expect(idFromPath('/a/$id/'), id);
  });

  test('decodifica o segmento', () {
    expect(idFromPath('/a/abc%20def'), 'abc def');
  });

  for (final path in ['/a/', '/a', '/', '', '/qr/', '/b/$id', '/a/$id/extra', '/x/a/$id', '/a/%20', '/a/%E0%A4%A', '/a/%FF']) {
    test('caminho sem id válido: "$path" → null', () {
      expect(idFromPath(path), isNull);
    });
  }
}
