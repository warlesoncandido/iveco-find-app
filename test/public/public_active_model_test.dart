import 'package:flutter_test/flutter_test.dart';
import 'package:iveco_find/src/modules/public/public_active_model.dart';

void main() {
  test('fromJson lê os 4 campos públicos', () {
    final active = PublicActive.fromJson({
      'nome': 'Furadeira',
      'codigoInterno': 'FER-000123',
      'localidade': 'Sete Lagoas',
      'status': 'EM_USO',
    });
    expect(active.nome, 'Furadeira');
    expect(active.codigoInterno, 'FER-000123');
    expect(active.localidade, 'Sete Lagoas');
    expect(active.status, 'EM_USO');
  });

  test('fromJson falha sem campo obrigatório', () {
    expect(() => PublicActive.fromJson({'nome': 'Furadeira'}), throwsA(isA<TypeError>()));
  });
}
