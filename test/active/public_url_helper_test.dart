import 'package:flutter_test/flutter_test.dart';
import 'package:iveco_find/src/shared/utils/helpers/public_url_helper.dart';

void main() {
  const id = '3f2b9c1e-0000-4000-8000-000000000001';

  test('usa PUBLIC_URL quando definida', () {
    expect(
      PublicUrl.ativo(id, publicUrl: 'https://find.exemplo.com', baseUrl: 'http://10.0.2.2:3000'),
      'https://find.exemplo.com/a/$id',
    );
  });

  test('cai no BASE_URL quando PUBLIC_URL está vazia', () {
    expect(
      PublicUrl.ativo(id, publicUrl: '', baseUrl: 'http://localhost:3000'),
      'http://localhost:3000/a/$id',
    );
  });

  test('não gera barra dupla quando a origem termina em /', () {
    expect(
      PublicUrl.ativo(id, publicUrl: 'https://find.exemplo.com/', baseUrl: ''),
      'https://find.exemplo.com/a/$id',
    );
    expect(
      PublicUrl.ativo(id, publicUrl: '', baseUrl: 'http://localhost:3000//'),
      'http://localhost:3000/a/$id',
    );
  });
}
