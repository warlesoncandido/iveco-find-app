import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iveco_find/src/core/services/dio_client.dart';

import '../user/fakes.dart';

/// Requisição vista pelo adapter falso.
class _Call {
  final String method;
  final String path;
  final String? authorization;
  final Object? body;
  _Call(this.method, this.path, this.authorization, this.body);
}

typedef _Handler = Future<ResponseBody> Function(RequestOptions options);

/// Adapter HTTP falso: grava as chamadas e responde por [handler].
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.handler);

  _Handler handler;
  final calls = <_Call>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    Object? body;
    if (requestStream != null) {
      final bytes = await requestStream.fold<List<int>>(
        [],
        (acc, chunk) => acc..addAll(chunk),
      );
      final text = utf8.decode(bytes, allowMalformed: true);
      try {
        body = json.decode(text);
      } on FormatException {
        body = text; // multipart e outros corpos não JSON
      }
    }
    calls.add(
      _Call(
        options.method,
        options.path,
        options.headers['Authorization'] as String?,
        body,
      ),
    );
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(int status, Object body) => ResponseBody.fromString(
  json.encode(body),
  status,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);

ResponseBody _unauthorized() =>
    _json(401, {'status': 401, 'codigo': 'NAO_AUTENTICADO'});

ResponseBody _refreshInvalid() =>
    _json(401, {'status': 401, 'codigo': 'REFRESH_INVALIDO'});

const _refreshPath = '/api/v1/auth/refresh';

Map<String, dynamic> _session({String token = 'old', String? refresh = 'r1'}) =>
    {
      'token': token,
      if (refresh != null) 'refreshToken': refresh,
      'trocaSenhaObrigatoria': false,
      'usuario': {
        'id': 'u1',
        'nome': 'Maria',
        'email': 'maria@iveco.com',
        'perfil': 'GESTOR',
      },
    };

void main() {
  late FakeLocalStorage storage;
  late _FakeAdapter adapter;
  late ClientDio client;
  late int expiredCalls;

  /// API falsa: aceita só `Bearer <validToken>`; o refresh troca `r1` por `new`/`r2`.
  String validToken = 'new';

  Future<ResponseBody> api(RequestOptions o) async {
    if (o.path == _refreshPath) {
      return _json(200, {'token': 'new', 'refreshToken': 'r2'});
    }
    if (o.headers['Authorization'] == 'Bearer $validToken') {
      return _json(200, {'path': o.path});
    }
    return _unauthorized();
  }

  Map<String, dynamic>? stored() {
    final raw = storage.values['auth'];
    return raw == null ? null : json.decode(raw) as Map<String, dynamic>;
  }

  int refreshCount() =>
      adapter.calls.where((c) => c.path == _refreshPath).length;

  setUp(() {
    validToken = 'new';
    storage = FakeLocalStorage()..values['auth'] = json.encode(_session());
    adapter = _FakeAdapter(api);
    expiredCalls = 0;
    client = ClientDio(
      storage: storage,
      baseUrl: 'http://api.test',
      httpClientAdapter: adapter,
      onSessionExpired: () => expiredCalls++,
    );
  });

  test(
    '401 em requisição autenticada: renova, grava o novo par e refaz com o token novo',
    () async {
      final r = await client.get<Map<String, dynamic>>(
        '/api/v1/ativos',
        isAuth: true,
      );

      expect(r.statusCode, 200);
      expect(r.data, {'path': '/api/v1/ativos'});
      expect(
        adapter.calls.map((c) => '${c.method} ${c.path} ${c.authorization}'),
        [
          'GET /api/v1/ativos Bearer old',
          'POST $_refreshPath null',
          'GET /api/v1/ativos Bearer new',
        ],
      );
      expect(adapter.calls[1].body, {'refreshToken': 'r1'});
      // Novo par gravado, mantendo Usuário e trocaSenhaObrigatoria.
      final saved = stored()!;
      expect(saved['token'], 'new');
      expect(saved['refreshToken'], 'r2');
      expect(saved['trocaSenhaObrigatoria'], false);
      expect(saved['usuario'], containsPair('id', 'u1'));
      expect(saved['usuario'], containsPair('perfil', 'GESTOR'));
      expect(expiredCalls, 0);
    },
  );

  test(
    '401s concorrentes: uma única renovação; todas refeitas com o token novo',
    () async {
      final refreshGate = Completer<void>();
      adapter.handler = (o) async {
        if (o.path == _refreshPath) await refreshGate.future;
        return api(o);
      };

      final futures = [
        for (var i = 0; i < 3; i++)
          client.get<Map<String, dynamic>>('/api/v1/r$i', isAuth: true),
      ];
      // Deixa as três falharem e esperarem a renovação em voo.
      await Future<void>.delayed(const Duration(milliseconds: 50));
      refreshGate.complete();
      final responses = await Future.wait(futures);

      expect(responses.map((r) => r.data!['path']), [
        '/api/v1/r0',
        '/api/v1/r1',
        '/api/v1/r2',
      ]);
      expect(refreshCount(), 1);
      final retried = adapter.calls.where(
        (c) => c.path != _refreshPath && c.authorization == 'Bearer new',
      );
      expect(retried, hasLength(3));
    },
  );

  test(
    '401 de requisição enviada com token já renovado por outra: refaz sem nova renovação',
    () async {
      // A sessão salva já tem o par novo, mas a requisição saiu com o antigo.
      final gate = Completer<void>();
      adapter.handler = (o) async {
        if (o.path == '/api/v1/lenta' &&
            o.headers['Authorization'] == 'Bearer old') {
          await gate.future;
        }
        return api(o);
      };
      final slow = client.get<Map<String, dynamic>>(
        '/api/v1/lenta',
        isAuth: true,
      );
      await Future<void>.delayed(const Duration(milliseconds: 20));
      await client.get<Map<String, dynamic>>('/api/v1/rapida', isAuth: true);
      expect(refreshCount(), 1);
      gate.complete();

      final r = await slow;
      expect(r.statusCode, 200);
      expect(refreshCount(), 1);
    },
  );

  test(
    'refresh recusado (401): remove o auth salvo, chama onSessionExpired e propaga o 401',
    () async {
      adapter.handler = (o) async =>
          o.path == _refreshPath ? _refreshInvalid() : _unauthorized();

      await expectLater(
        client.get<dynamic>('/api/v1/ativos', isAuth: true),
        throwsA(
          isA<DioException>().having(
            (e) => e.response?.statusCode,
            'status',
            401,
          ),
        ),
      );
      expect(storage.values.containsKey('auth'), isFalse);
      expect(expiredCalls, 1);
      // A requisição original não é refeita.
      expect(
        adapter.calls.where((c) => c.path == '/api/v1/ativos'),
        hasLength(1),
      );
    },
  );

  test(
    'refresh recusado com 401s concorrentes: onSessionExpired uma única vez',
    () async {
      adapter.handler = (o) async =>
          o.path == _refreshPath ? _refreshInvalid() : _unauthorized();

      final results = await Future.wait([
        for (var i = 0; i < 3; i++)
          client
              .get<dynamic>('/api/v1/r$i', isAuth: true)
              .then<Object?>((r) => r, onError: (Object e) => e),
      ]);

      expect(results, everyElement(isA<DioException>()));
      expect(refreshCount(), 1);
      expect(expiredCalls, 1);
      expect(storage.values.containsKey('auth'), isFalse);
    },
  );

  test(
    'onSessionExpired que lança: as requisições em espera terminam (sem travar) e a sessão é limpa',
    () async {
      client = ClientDio(
        storage: storage,
        baseUrl: 'http://api.test',
        httpClientAdapter: adapter,
        onSessionExpired: () => throw StateError('falhou ao navegar'),
      );
      adapter.handler = (o) async =>
          o.path == _refreshPath ? _refreshInvalid() : _unauthorized();

      final results = await Future.wait([
        for (var i = 0; i < 2; i++)
          client
              .get<dynamic>('/api/v1/r$i', isAuth: true)
              .then<Object?>((r) => r, onError: (Object e) => e),
      ]).timeout(const Duration(seconds: 5));

      expect(
        results,
        everyElement(
          isA<DioException>().having(
            (e) => e.response?.statusCode,
            'status',
            401,
          ),
        ),
      );
      expect(refreshCount(), 1);
      expect(storage.values.containsKey('auth'), isFalse);

      // Sem refresh salvo, o mesmo caminho (fora do try) também não trava.
      storage.values['auth'] = json.encode(_session(refresh: null));
      await expectLater(
        client
            .get<dynamic>('/api/v1/ativos', isAuth: true)
            .timeout(const Duration(seconds: 5)),
        throwsA(isA<DioException>()),
      );
    },
  );

  test(
    'sessão salva antes do refresh token (sem refreshToken): vai direto ao login, sem chamar a API',
    () async {
      storage.values['auth'] = json.encode(_session(refresh: null));

      await expectLater(
        client.get<dynamic>('/api/v1/ativos', isAuth: true),
        throwsA(isA<DioException>()),
      );
      expect(refreshCount(), 0);
      expect(storage.values.containsKey('auth'), isFalse);
      expect(expiredCalls, 1);
    },
  );

  test(
    'falha de rede no refresh: propaga o erro original e não limpa a sessão',
    () async {
      adapter.handler = (o) async {
        if (o.path == _refreshPath) {
          throw DioException.connectionError(
            requestOptions: o,
            reason: 'sem conexão',
          );
        }
        return _unauthorized();
      };

      await expectLater(
        client.get<dynamic>('/api/v1/ativos', isAuth: true),
        throwsA(
          isA<DioException>().having(
            (e) => e.response?.statusCode,
            'status',
            401,
          ),
        ),
      );
      expect(stored(), _session());
      expect(expiredCalls, 0);
    },
  );

  test('refresh com erro de servidor (500): não limpa a sessão', () async {
    adapter.handler = (o) async => o.path == _refreshPath
        ? _json(500, {'codigo': 'ERRO_INTERNO'})
        : _unauthorized();

    await expectLater(
      client.get<dynamic>('/api/v1/ativos', isAuth: true),
      throwsA(isA<DioException>()),
    );
    expect(stored(), _session());
    expect(expiredCalls, 0);
  });

  test('requisição isAuth: false com 401 não renova', () async {
    await expectLater(
      client.post<dynamic>(
        '/api/v1/auth/login',
        data: {'email': 'x', 'senha': 'y'},
      ),
      throwsA(
        isA<DioException>().having(
          (e) => e.response?.statusCode,
          'status',
          401,
        ),
      ),
    );
    expect(refreshCount(), 0);
    expect(adapter.calls.single.authorization, isNull);
    expect(stored(), _session());
  });

  test(
    'cada requisição é refeita no máximo uma vez: 401 depois da renovação é propagado',
    () async {
      validToken = 'nunca-aceito';

      await expectLater(
        client.get<dynamic>('/api/v1/ativos', isAuth: true),
        throwsA(
          isA<DioException>().having(
            (e) => e.response?.statusCode,
            'status',
            401,
          ),
        ),
      );
      expect(refreshCount(), 1);
      expect(
        adapter.calls.where((c) => c.path == '/api/v1/ativos'),
        hasLength(2),
      );
      expect(expiredCalls, 0);
    },
  );

  test('erros que não são 401 passam direto, sem renovar', () async {
    adapter.handler = (o) async => _json(403, {'codigo': 'SEM_PERMISSAO'});

    await expectLater(
      client.get<dynamic>('/api/v1/ativos', isAuth: true),
      throwsA(
        isA<DioException>().having(
          (e) => e.response?.statusCode,
          'status',
          403,
        ),
      ),
    );
    expect(refreshCount(), 0);
  });

  test(
    '401 no envio multipart: renova e refaz com uma cópia do FormData',
    () async {
      final r = await client.postMultipart<Map<String, dynamic>>(
        '/api/v1/ativos/x1/anexos',
        isAuth: true,
        data: FormData.fromMap({
          'categoria': 'NF',
          'arquivo': MultipartFile.fromBytes(
            utf8.encode('%PDF-1'),
            filename: 'nf.pdf',
          ),
        }),
      );

      expect(r.statusCode, 200);
      expect(
        adapter.calls.map((c) => '${c.method} ${c.path} ${c.authorization}'),
        [
          'POST /api/v1/ativos/x1/anexos Bearer old',
          'POST $_refreshPath null',
          'POST /api/v1/ativos/x1/anexos Bearer new',
        ],
      );
      expect(adapter.calls.last.body, contains('filename="nf.pdf"'));
      expect(adapter.calls.last.body, contains('%PDF-1'));
    },
  );

  test('getBytes devolve o corpo binário', () async {
    adapter.handler = (o) async => ResponseBody.fromBytes(
      [0x25, 0x50, 0x44, 0x46],
      200,
      headers: {
        Headers.contentTypeHeader: ['application/pdf'],
      },
    );
    final r = await client.getBytes(
      '/api/v1/ativos/x1/anexos/a1/conteudo',
      isAuth: true,
    );
    expect(r.data, [0x25, 0x50, 0x44, 0x46]);
  });
}
