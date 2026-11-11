import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iveco_find/src/modules/public/public_active_repository.dart';

/// Responde cada requisição com o status e o corpo dados, sem rede.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.status, [this.body = '{}', this.throwError = false]);

  final int status;
  final String body;
  final bool throwError;
  final paths = <String>[];

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<List<int>>? requestStream, Future<void>? cancelFuture) async {
    paths.add(options.path);
    if (throwError) {
      throw DioException.connectionError(requestOptions: options, reason: 'offline');
    }
    return ResponseBody.fromString(body, status, headers: {
      Headers.contentTypeHeader: ['application/json'],
    });
  }

  @override
  void close({bool force = false}) {}
}

PublicActiveRepository _repo(_FakeAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'http://api.local'))..httpClientAdapter = adapter;
  return PublicActiveRepository(dio: dio);
}

void main() {
  test('200: Right com o Ativo', () async {
    final adapter = _FakeAdapter(200, '{"nome":"Furadeira","codigoInterno":"FER-1","localidade":"SL","status":"DISPONIVEL"}');
    final result = await _repo(adapter).fetch('abc');
    expect(adapter.paths, ['/api/v1/publico/ativos/abc']);
    expect(result.isRight(), isTrue);
    result.fold((_) => fail('esperava Right'), (a) => expect(a.nome, 'Furadeira'));
  });

  test('404: Left com código NOT_FOUND', () async {
    final result = await _repo(_FakeAdapter(404, '{"codigo":"ATIVO_NAO_ENCONTRADO"}')).fetch('abc');
    result.fold((f) => expect(f.code, PublicActiveRepository.notFound), (_) => fail('esperava Left'));
  });

  test('500: Left sem código NOT_FOUND', () async {
    final result = await _repo(_FakeAdapter(500)).fetch('abc');
    result.fold((f) => expect(f.code, isNot(PublicActiveRepository.notFound)), (_) => fail('esperava Left'));
  });

  test('falha de rede: Left sem código NOT_FOUND', () async {
    final result = await _repo(_FakeAdapter(0, '', true)).fetch('abc');
    result.fold((f) => expect(f.code, isNot(PublicActiveRepository.notFound)), (_) => fail('esperava Left'));
  });

  test('id é codificado no caminho', () async {
    final adapter = _FakeAdapter(404);
    await _repo(adapter).fetch('a/b');
    expect(adapter.paths, ['/api/v1/publico/ativos/a%2Fb']);
  });
}
