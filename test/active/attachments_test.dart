import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:iveco_find/src/core/l10n/locale_controller.dart';
import 'package:iveco_find/src/core/services/dio_client.dart';
import 'package:iveco_find/src/core/l10n/localized_app.dart';
import 'package:iveco_find/src/modules/home/pages/actives/actives_module.dart';
import 'package:iveco_find/src/modules/home/pages/actives/components/active_attachments_tab.dart';
import 'package:iveco_find/src/modules/home/pages/actives/controllers/active_attachments_controller.dart';
import 'package:iveco_find/src/modules/home/pages/actives/controllers/active_details_controller.dart';
import 'package:iveco_find/src/modules/home/pages/actives/pages/active_details_page.dart';
import 'package:iveco_find/src/modules/home/pages/actives/pages/attachment_viewer_page.dart';
import 'package:iveco_find/src/shared/models/attachment_model.dart';
import 'package:iveco_find/src/shared/repositories/attachment_repository.dart';
import 'package:iveco_find/src/shared/services/attachment_cache/attachment_cache.dart';
import 'package:iveco_find/src/shared/services/attachment_compressor.dart';
import 'package:iveco_find/src/shared/services/attachment_opener/attachment_opener.dart';
import 'package:iveco_find/src/shared/utils/behaviour_page.dart';
import 'package:iveco_find/src/shared/utils/failure.dart';

import '../helpers/localized_app.dart';
import '../user/fakes.dart';

Map<String, dynamic> _json({
  String id = 'a1',
  String nome = 'NF 123.pdf',
  String categoria = 'NF',
  String tipo = 'application/pdf',
  int tamanho = 2048,
}) => {
  'id': id,
  'nome': nome,
  'categoria': categoria,
  'tipoConteudo': tipo,
  'tamanhoBytes': tamanho,
  'enviadoEm': '2026-11-24T12:00:00Z',
  'enviadoPor': {'id': 'u1', 'nome': 'Maria', 'ativo': true},
};

AttachmentModel _model({
  String id = 'a1',
  String nome = 'NF 123.pdf',
  String tipo = 'application/pdf',
  int tamanho = 2048,
}) => AttachmentModel.fromJson(
  _json(id: id, nome: nome, tipo: tipo, tamanho: tamanho),
);

class _FakeRepository implements AttachmentRepository {
  List<AttachmentModel> items = [];
  Failure? failure;
  final uploads = <(String, String, AttachmentCategory, int)>[];
  final renames = <(String, String)>[];
  final removes = <String>[];
  final downloads = <String>[];

  /// Se definido, envio, renomeação e remoção só respondem quando ele completar.
  Completer<void>? gate;

  @override
  ClientDio get dio => throw UnimplementedError();

  @override
  Future<Either<Failure, List<AttachmentModel>>> getAttachments(
    String activeId,
  ) async => failure != null ? Left(failure!) : Right(items);

  @override
  Future<Either<Failure, AttachmentModel>> upload({
    required String activeId,
    required Uint8List bytes,
    required String fileName,
    required AttachmentCategory category,
    void Function(double progress)? onProgress,
  }) async {
    uploads.add((activeId, fileName, category, bytes.length));
    if (gate != null) await gate!.future;
    onProgress?.call(0.5);
    if (failure != null) return Left(failure!);
    return Right(
      AttachmentModel.fromJson(
        _json(id: 'novo', nome: fileName, categoria: category.value),
      ),
    );
  }

  @override
  Future<Either<Failure, Uint8List>> download({
    required String activeId,
    required String attachmentId,
  }) async {
    downloads.add(attachmentId);
    if (failure != null) return Left(failure!);
    return Right(Uint8List.fromList([0x25, 0x50, 0x44, 0x46]));
  }

  @override
  Future<Either<Failure, AttachmentModel>> rename({
    required String activeId,
    required String attachmentId,
    required String name,
  }) async {
    renames.add((attachmentId, name));
    if (gate != null) await gate!.future;
    if (failure != null) return Left(failure!);
    return Right(AttachmentModel.fromJson(_json(id: attachmentId, nome: name)));
  }

  @override
  Future<Either<Failure, bool>> remove({
    required String activeId,
    required String attachmentId,
  }) async {
    removes.add(attachmentId);
    if (gate != null) await gate!.future;
    if (failure != null) return Left(failure!);
    return const Right(true);
  }
}

class _FakeOpener implements AttachmentOpener {
  final opened = <(String, int, String, String)>[];
  bool fail = false;

  @override
  Future<void> open(
    String id,
    Uint8List bytes,
    String fileName,
    String mimeType,
  ) async {
    if (fail) throw Exception('sem app');
    opened.add((id, bytes.length, fileName, mimeType));
  }
}

/// Cache fake em memória: registra as chamadas; [failWrites] faz o `put` lançar.
class _FakeCache implements AttachmentCache {
  final entries = <String, Uint8List>{};
  final removed = <String>[];
  bool failWrites = false;

  @override
  Future<Uint8List?> get(String id, int expectedSize) async {
    final bytes = entries[id];
    return bytes != null && bytes.length == expectedSize ? bytes : null;
  }

  @override
  Future<void> put(String id, Uint8List bytes) async {
    if (failWrites) throw const _CacheWriteError();
    entries[id] = bytes;
  }

  @override
  Future<void> remove(String id) async {
    removed.add(id);
    entries.remove(id);
  }
}

class _CacheWriteError implements Exception {
  const _CacheWriteError();
}

/// PNG 1×1 válido.
final _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
);

/// Compactador fake: devolve [result] (ou o original) e registra as chamadas.
class _FakeCompressor implements AttachmentCompressor {
  final calls = <String>[];
  Uint8List? result;

  /// Se definido, a compactação só termina quando ele completar.
  Completer<void>? gate;

  @override
  Future<Uint8List> compress(Uint8List bytes, String fileName) async {
    calls.add(fileName);
    if (gate != null) await gate!.future;
    return result ?? bytes;
  }
}

void main() {
  group('ActiveDetailsPage', pageTests);

  group('AttachmentModel', () {
    test('fromJson e helpers', () {
      final a = _model();
      expect(a.categoria, AttachmentCategory.nf);
      expect(a.isPdf, isTrue);
      expect(a.isImage, isFalse);
      expect(a.enviadoEm, DateTime.utc(2026, 11, 24, 12));
      expect(a.enviadoPor.nome, 'Maria');
      expect(_model(tipo: 'image/webp').isImage, isTrue);
    });

    test('categoria desconhecida não quebra o parse', () {
      final a = AttachmentModel.fromJson(_json(categoria: 'BOLETO'));
      expect(a.categoria, AttachmentCategory.manual);
    });

    test('formatSize', () {
      expect(AttachmentModel.formatSize(512), '512 B');
      expect(AttachmentModel.formatSize(1024), '1 KB');
      expect(AttachmentModel.formatSize(1536), '1,5 KB');
      expect(AttachmentModel.formatSize(20 * 1024 * 1024), '20 MB');
    });
  });

  group('AttachmentRepository', () {
    late FakeClientDio dio;
    late AttachmentRepository repository;

    setUp(() {
      dio = FakeClientDio();
      repository = AttachmentRepository(dio: dio);
    });

    test('lista: GET autenticado e parse', () async {
      dio.response = [_json(), _json(id: 'a2', tipo: 'image/png')];
      final r = await repository.getAttachments('x1');
      expect(dio.calls.single.method, 'GET');
      expect(dio.calls.single.path, '/api/v1/ativos/x1/anexos');
      expect(dio.calls.single.isAuth, isTrue);
      expect(r.getOrElse(() => []).map((e) => e.id), ['a1', 'a2']);
    });

    test('envio: multipart com categoria e arquivo', () async {
      dio.response = _json();
      final progress = <double>[];
      final r = await repository.upload(
        activeId: 'x1',
        bytes: Uint8List.fromList([1, 2, 3]),
        fileName: 'nf.pdf',
        category: AttachmentCategory.laudo,
        onProgress: progress.add,
      );
      expect(r.isRight(), isTrue);
      final call = dio.calls.single;
      expect(call.method, 'POST');
      expect(call.path, '/api/v1/ativos/x1/anexos');
      expect(call.isAuth, isTrue);
      final form = call.data as FormData;
      expect(form.fields.map((e) => [e.key, e.value]), [
        ['categoria', 'LAUDO'],
      ]);
      expect(form.files.single.key, 'arquivo');
      expect(form.files.single.value.filename, 'nf.pdf');
      expect(form.files.single.value.length, 3);
      expect(progress, [1.0]);
    });

    test('download: bytes do conteúdo', () async {
      dio.response = <int>[1, 2, 3];
      final r = await repository.download(activeId: 'x1', attachmentId: 'a1');
      expect(dio.calls.single.path, '/api/v1/ativos/x1/anexos/a1/conteudo');
      expect(r.getOrElse(() => Uint8List(0)), [1, 2, 3]);
    });

    test('renomear: PATCH com nome aparado', () async {
      dio.response = _json(nome: 'NF 123');
      await repository.rename(
        activeId: 'x1',
        attachmentId: 'a1',
        name: '  NF 123 ',
      );
      final call = dio.calls.single;
      expect(call.method, 'PATCH');
      expect(call.path, '/api/v1/ativos/x1/anexos/a1');
      expect(call.data, {'nome': 'NF 123'});
    });

    test('remover: DELETE', () async {
      final r = await repository.remove(activeId: 'x1', attachmentId: 'a1');
      expect(dio.calls.single.method, 'DELETE');
      expect(dio.calls.single.path, '/api/v1/ativos/x1/anexos/a1');
      expect(r, const Right<Failure, bool>(true));
    });

    test('erro: usa detail e codigo do Problem Details', () async {
      dio.error = problemDetails(422, 'ATIVO_BAIXADO', 'Ativo Baixado');
      final r = await repository.remove(activeId: 'x1', attachmentId: 'a1');
      final f = r.swap().getOrElse(() => throw 'deveria falhar');
      expect(f.code, 'ATIVO_BAIXADO');
      expect(f.message, 'Ativo Baixado');
    });

    test('API sem armazenamento (501) vira mensagem própria', () async {
      dio.error = problemDetails(501, 'NAO_IMPLEMENTADO', 'x');
      final r = await repository.getAttachments('x1');
      final f = r.swap().getOrElse(() => throw 'deveria falhar');
      expect(f.code, AttachmentRepository.notAvailable);
      expect(f.message, contains('armazenamento'));
    });
  });

  group('ActiveAttachmentsController', () {
    late _FakeRepository repository;
    late _FakeOpener opener;
    late _FakeCompressor compressor;
    late _FakeCache cache;
    late ActiveAttachmentsController controller;

    setUp(() {
      // O download fake devolve 4 bytes: o tamanho do Anexo bate com ele.
      repository = _FakeRepository()..items = [_model(tamanho: 4)];
      opener = _FakeOpener();
      compressor = _FakeCompressor();
      cache = _FakeCache();
      controller = ActiveAttachmentsController(
        repository: repository,
        opener: opener,
        compressor: compressor,
        cache: cache,
      );
    });

    test('init carrega a lista', () async {
      await controller.init('x1');
      expect(controller.behaviour, Behaviour.success);
      expect(controller.attachments.map((e) => e.id), ['a1']);
    });

    test('falha ao carregar guarda a mensagem', () async {
      repository.failure = Failure(message: 'sem S3');
      await controller.init('x1');
      expect(controller.behaviour, Behaviour.error);
      expect(controller.loadError, 'sem S3');
    });

    test('envio ok entra no topo da lista e zera o progresso', () async {
      await controller.init('x1');
      var ok = false;
      final progress = <double?>[];
      controller.addListener(() => progress.add(controller.uploadProgress));
      await controller.upload(
        PickedAttachmentFile(
          bytes: Uint8List.fromList([1, 2]),
          name: 'foto.jpg',
        ),
        AttachmentCategory.foto,
        onSuccess: () => ok = true,
        onError: (_) => fail('não deveria falhar'),
      );
      expect(ok, isTrue);
      expect(repository.uploads.single, (
        'x1',
        'foto.jpg',
        AttachmentCategory.foto,
        2,
      ));
      expect(controller.attachments.map((e) => e.id), ['novo', 'a1']);
      expect(progress, containsAllInOrder([0.0, 0.5, null]));
      expect(controller.uploading, isFalse);
    });

    test('arquivo acima de 20 MB nem chega à API', () async {
      await controller.init('x1');
      String? error;
      await controller.upload(
        PickedAttachmentFile(
          bytes: Uint8List(AttachmentModel.maxBytes + 1),
          name: 'grande.pdf',
        ),
        AttachmentCategory.manual,
        onSuccess: () => fail('não deveria enviar'),
        onError: (m) => error = m,
      );
      expect(error, contains('20 MB'));
      expect(repository.uploads, isEmpty);
    });

    test('JPEG acima de 20 MB que compacta para menos é enviado', () async {
      await controller.init('x1');
      compressor.result = Uint8List(4 * 1024 * 1024);
      final preparing = <bool>[];
      controller.addListener(() => preparing.add(controller.preparing));
      var ok = false;
      await controller.upload(
        PickedAttachmentFile(
          bytes: Uint8List(25 * 1024 * 1024),
          name: 'grande.jpg',
        ),
        AttachmentCategory.foto,
        onSuccess: () => ok = true,
        onError: (m) => fail('não deveria falhar: $m'),
      );
      expect(ok, isTrue);
      expect(compressor.calls, ['grande.jpg']);
      expect(repository.uploads.single.$4, 4 * 1024 * 1024);
      expect(preparing.first, isTrue);
      expect(controller.preparing, isFalse);
    });

    test(
      'imagem que continua acima de 20 MB após compactar não envia',
      () async {
        await controller.init('x1');
        compressor.result = Uint8List(AttachmentModel.maxBytes + 1);
        final preparing = <bool>[];
        controller.addListener(() => preparing.add(controller.preparing));
        String? error;
        await controller.upload(
          PickedAttachmentFile(
            bytes: Uint8List(AttachmentModel.maxBytes + 10),
            name: 'enorme.jpg',
          ),
          AttachmentCategory.foto,
          onSuccess: () => fail('não deveria enviar'),
          onError: (m) => error = m,
        );
        expect(error, L10n.current.attachmentTooLarge);
        expect(repository.uploads, isEmpty);
        expect(preparing, isNotEmpty);
        expect(preparing.last, isFalse);
      },
    );

    test('segundo envio durante a compactação é ignorado', () async {
      await controller.init('x1');
      final gate = compressor.gate = Completer<void>();
      final file = PickedAttachmentFile(
        bytes: Uint8List.fromList([1, 2]),
        name: 'foto.jpg',
      );
      final first = controller.upload(
        file,
        AttachmentCategory.foto,
        onSuccess: () {},
        onError: (m) => fail('não deveria falhar: $m'),
      );
      expect(controller.preparing, isTrue);
      await controller.upload(
        file,
        AttachmentCategory.foto,
        onSuccess: () => fail('não deveria enviar'),
        onError: (m) => fail('não deveria falhar: $m'),
      );
      gate.complete();
      await first;
      expect(compressor.calls, hasLength(1));
      expect(repository.uploads, hasLength(1));
    });

    test('trocar de Ativo durante a compactação descarta o envio', () async {
      await controller.init('x1');
      final gate = compressor.gate = Completer<void>();
      var callbacks = 0;
      final upload = controller.upload(
        PickedAttachmentFile(
          bytes: Uint8List.fromList([1, 2]),
          name: 'foto.jpg',
        ),
        AttachmentCategory.foto,
        onSuccess: () => callbacks++,
        onError: (_) => callbacks++,
      );
      await controller.init('x2');
      gate.complete();
      await upload;
      expect(repository.uploads, isEmpty);
      expect(callbacks, 0);
      expect(controller.preparing, isFalse);
    });

    test('foto da câmera não é recompactada', () async {
      await controller.init('x1');
      compressor.result = Uint8List(1);
      final photo = Uint8List.fromList(List.generate(10, (i) => i));
      await controller.upload(
        PickedAttachmentFile(
          bytes: photo,
          name: 'foto_1.jpg',
          compressed: true,
        ),
        AttachmentCategory.foto,
        onSuccess: () {},
        onError: (m) => fail('não deveria falhar: $m'),
      );
      expect(compressor.calls, isEmpty);
      expect(repository.uploads.single.$4, 10);
    });

    test('envio com erro da API repassa a mensagem', () async {
      await controller.init('x1');
      repository.failure = Failure(
        message: 'Ativo Baixado',
        code: 'ATIVO_BAIXADO',
      );
      String? error;
      await controller.upload(
        PickedAttachmentFile(bytes: Uint8List.fromList([1]), name: 'a.pdf'),
        AttachmentCategory.nf,
        onSuccess: () => fail('não deveria'),
        onError: (m) => error = m,
      );
      expect(error, 'Ativo Baixado');
      expect(controller.attachments.map((e) => e.id), ['a1']);
    });

    test('primeira abertura baixa uma vez e guarda no cache', () async {
      await controller.init('x1');
      final bytes = await controller.loadContent(
        controller.attachments.first,
        onError: (_) => fail('x'),
      );
      expect(bytes, [0x25, 0x50, 0x44, 0x46]);
      expect(repository.downloads, ['a1']);
      expect(cache.entries['a1'], bytes);
      expect(opener.opened, isEmpty);
      expect(controller.openingId, isNull);
    });

    test('segunda abertura não chama o repositório', () async {
      await controller.init('x1');
      final a = controller.attachments.first;
      await controller.loadContent(a, onError: (_) => fail('x'));
      final again = await controller.loadContent(a, onError: (_) => fail('x'));
      expect(again, [0x25, 0x50, 0x44, 0x46]);
      expect(repository.downloads, ['a1']);
    });

    test('cache com tamanho divergente baixa de novo e substitui', () async {
      await controller.init('x1');
      cache.entries['a1'] = Uint8List.fromList([1, 2, 3]);
      final bytes = await controller.loadContent(
        controller.attachments.first,
        onError: (_) => fail('x'),
      );
      expect(repository.downloads, ['a1']);
      expect(bytes, hasLength(4));
      expect(cache.entries['a1'], hasLength(4));
    });

    test(
      'download com tamanho diferente de tamanhoBytes não vai ao cache',
      () async {
        repository.items = [_model(tamanho: 2048)];
        await controller.init('x1');
        final bytes = await controller.loadContent(
          controller.attachments.first,
          onError: (_) => fail('x'),
        );
        expect(bytes, [0x25, 0x50, 0x44, 0x46]);
        expect(cache.entries, isEmpty);
      },
    );

    test('falha ao gravar no cache não impede abrir', () async {
      await controller.init('x1');
      cache.failWrites = true;
      final bytes = await controller.loadContent(
        controller.attachments.first,
        onError: (_) => fail('x'),
      );
      expect(bytes, hasLength(4));
      expect(controller.openingId, isNull);
    });

    test('falha no download avisa o erro e não devolve conteúdo', () async {
      await controller.init('x1');
      repository.failure = Failure(message: 'Erro ao baixar o arquivo.');
      String? error;
      final bytes = await controller.loadContent(
        controller.attachments.first,
        onError: (m) => error = m,
      );
      expect(bytes, isNull);
      expect(error, 'Erro ao baixar o arquivo.');
      expect(cache.entries, isEmpty);
      expect(controller.openingId, isNull);
    });

    test('abrir em outro app entrega os mesmos bytes ao opener', () async {
      await controller.init('x1');
      await controller.openExternally(
        controller.attachments.first,
        Uint8List(7),
        onError: (_) => fail('x'),
      );
      expect(opener.opened.single, ('a1', 7, 'NF 123.pdf', 'application/pdf'));
      expect(repository.downloads, isEmpty);
    });

    test('abrir em outro app sem app compatível avisa o erro', () async {
      await controller.init('x1');
      opener.fail = true;
      String? error;
      await controller.openExternally(
        controller.attachments.first,
        Uint8List(4),
        onError: (m) => error = m,
      );
      expect(error, L10n.current.attachmentOpenError);
    });

    test(
      'renomear troca o item na lista; nome vazio não chama a API',
      () async {
        await controller.init('x1');
        String? error;
        await controller.rename(
          controller.attachments.first,
          '   ',
          onSuccess: () => fail('x'),
          onError: (m) => error = m,
        );
        expect(error, isNotNull);
        expect(repository.renames, isEmpty);

        await controller.rename(
          controller.attachments.first,
          ' NF 999 ',
          onSuccess: () {},
          onError: (_) => fail('x'),
        );
        expect(repository.renames.single, ('a1', 'NF 999'));
        expect(controller.attachments.single.nome, 'NF 999');
      },
    );

    test(
      'resultado de envio/renomeação/remoção de outro Ativo é descartado',
      () async {
        await controller.init('x1');
        final gate = repository.gate = Completer<void>();
        var callbacks = 0;
        final upload = controller.upload(
          PickedAttachmentFile(bytes: Uint8List.fromList([1]), name: 'a.pdf'),
          AttachmentCategory.nf,
          onSuccess: () => callbacks++,
          onError: (_) => callbacks++,
        );
        final rename = controller.rename(
          controller.attachments.first,
          'novo nome',
          onSuccess: () => callbacks++,
          onError: (_) => callbacks++,
        );
        final remove = controller.remove(
          controller.attachments.first,
          onSuccess: () => callbacks++,
          onError: (_) => callbacks++,
        );
        repository.items = [_model(id: 'b1', nome: 'outro.pdf')];
        await controller.init('x2');
        gate.complete();
        await Future.wait([upload, rename, remove]);

        expect(callbacks, 0);
        expect(controller.activeId, 'x2');
        expect(controller.attachments.map((e) => [e.id, e.nome]), [
          ['b1', 'outro.pdf'],
        ]);
        expect(controller.uploadProgress, isNull);
      },
    );

    test('remover tira da lista', () async {
      await controller.init('x1');
      await controller.remove(
        controller.attachments.first,
        onSuccess: () {},
        onError: (_) => fail('x'),
      );
      expect(repository.removes, ['a1']);
      expect(controller.attachments, isEmpty);
    });

    test('remover apaga a entrada do cache', () async {
      await controller.init('x1');
      final a = controller.attachments.first;
      await controller.loadContent(a, onError: (_) => fail('x'));
      expect(cache.entries, contains('a1'));
      await controller.remove(a, onSuccess: () {}, onError: (_) => fail('x'));
      expect(cache.removed, ['a1']);
      expect(cache.entries, isEmpty);
    });

    test('remoção recusada pela API mantém o cache', () async {
      await controller.init('x1');
      cache.entries['a1'] = Uint8List(4);
      repository.failure = Failure(message: 'Ativo Baixado');
      await controller.remove(
        controller.attachments.first,
        onSuccess: () => fail('x'),
        onError: (_) {},
      );
      expect(cache.removed, isEmpty);
      expect(cache.entries, contains('a1'));
    });
  });

  group('ActiveAttachmentsTab', () {
    late ActiveAttachmentsController controller;
    late List<(String, int)> viewed;

    setUp(() async {
      viewed = [];
      controller = ActiveAttachmentsController(
        repository: _FakeRepository()
          ..items = [
            _model(tamanho: 4),
            _model(id: 'a2', nome: 'foto.png', tipo: 'image/png'),
          ],
        opener: _FakeOpener(),
        compressor: _FakeCompressor(),
        cache: _FakeCache(),
      );
      await controller.init('x1');
    });

    Widget app(bool canEdit) => localizedApp(
      home: Scaffold(
        body: ActiveAttachmentsTab(
          controller: controller,
          canEdit: canEdit,
          openViewer: (context, a, bytes) => viewed.add((a.id, bytes.length)),
        ),
      ),
    );

    testWidgets('com canEdit mostra enviar e o menu de renomear/remover', (
      tester,
    ) async {
      await tester.pumpWidget(app(true));
      expect(find.byKey(const Key('attachment-add')), findsOneWidget);
      expect(find.byKey(const Key('attachment-menu-a1')), findsOneWidget);
      expect(find.text('NF 123.pdf'), findsOneWidget);
      expect(find.textContaining('Nota fiscal · 2 KB'), findsWidgets);
      expect(find.byIcon(Icons.picture_as_pdf), findsOneWidget);
      expect(find.byIcon(Icons.image_outlined), findsOneWidget);
    });

    testWidgets('sem canEdit (CONSULTA ou Baixado) só lista e abre', (
      tester,
    ) async {
      await tester.pumpWidget(app(false));
      expect(find.text('NF 123.pdf'), findsOneWidget);
      expect(find.byKey(const Key('attachment-add')), findsNothing);
      expect(find.byKey(const Key('attachment-menu-a1')), findsNothing);
      await tester.tap(find.text('NF 123.pdf'));
      await tester.pumpAndSettle();
      expect(viewed, [('a1', 4)]);
      expect((controller.opener as _FakeOpener).opened, isEmpty);
    });

    testWidgets('preparando mostra a barra indeterminada e trava o FAB', (
      tester,
    ) async {
      controller.preparing = true;
      await tester.pumpWidget(app(true));
      expect(find.text('Preparando arquivo…'), findsOneWidget);
      expect(find.byKey(const Key('attachment-preparing')), findsOneWidget);
      final fab = tester.widget<FloatingActionButton>(
        find.byKey(const Key('attachment-add')),
      );
      expect(fab.onPressed, isNull);
    });

    testWidgets('lista vazia mostra a mensagem', (tester) async {
      controller.attachments = [];
      await tester.pumpWidget(app(true));
      expect(find.text('Nenhum arquivo anexado.'), findsOneWidget);
    });

    group('rota attachment-viewer', () {
      final viewerRoute = activiesModule.routes.whereType<GoRoute>().firstWhere(
        (r) => r.name == 'attachment-viewer',
      );
      late GoRouter router;

      setUp(() {
        GetIt.instance.registerSingleton<ActiveAttachmentsController>(
          controller,
        );
        router = GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => Scaffold(
                body: ActiveAttachmentsTab(
                  controller: controller,
                  canEdit: false,
                ),
              ),
            ),
            GoRoute(
              path: '/home',
              builder: (context, state) =>
                  const Scaffold(body: Text('home-fake')),
            ),
            viewerRoute,
          ],
        );
      });

      tearDown(() async {
        router.dispose();
        await GetIt.instance.reset();
      });

      Widget routerApp() => MaterialApp.router(
        locale: const Locale('pt'),
        supportedLocales: LocaleController.supportedLocales,
        localizationsDelegates: LocalizedApp.localizationsDelegates,
        routerConfig: router,
      );

      testWidgets('tocar no Anexo abre o visualizador com os bytes', (
        tester,
      ) async {
        await tester.pumpWidget(routerApp());
        await tester.tap(find.text('NF 123.pdf'));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        final page = tester.widget<AttachmentViewerPage>(
          find.byType(AttachmentViewerPage),
        );
        expect(page.attachment.id, 'a1');
        expect(page.bytes, [0x25, 0x50, 0x44, 0x46]);
      });

      testWidgets('sem extra (recarga/link direto) volta para a home', (
        tester,
      ) async {
        await tester.pumpWidget(routerApp());
        router.go('/attachment-viewer');
        await tester.pumpAndSettle();
        expect(find.byType(AttachmentViewerPage), findsNothing);
        expect(find.text('home-fake'), findsOneWidget);
      });
    });
  });

  group('AttachmentViewerPage', () {
    late _FakeOpener opener;
    late ActiveAttachmentsController controller;

    setUp(() {
      opener = _FakeOpener();
      controller = ActiveAttachmentsController(
        repository: _FakeRepository(),
        opener: opener,
        compressor: _FakeCompressor(),
        cache: _FakeCache(),
      );
    });

    testWidgets('imagem com zoom; "Abrir em outro app" usa os mesmos bytes', (
      tester,
    ) async {
      final a = _model(id: 'a2', nome: 'foto.png', tipo: 'image/png');
      await tester.pumpWidget(
        localizedApp(
          home: AttachmentViewerPage(
            attachment: a,
            bytes: _png,
            controller: controller,
          ),
        ),
      );
      expect(find.text('foto.png'), findsOneWidget);
      final viewer = tester.widget<InteractiveViewer>(
        find.byKey(const Key('attachment-viewer-image')),
      );
      expect(viewer.maxScale, 5);
      expect(find.byType(Image), findsOneWidget);
      expect(find.byTooltip('Abrir em outro app'), findsOneWidget);

      await tester.tap(find.byKey(const Key('attachment-open-external')));
      await tester.pump();
      expect(opener.opened.single, (
        'a2',
        _png.length,
        'foto.png',
        'image/png',
      ));
    });

    testWidgets('imagem inválida mostra a mensagem de erro', (tester) async {
      final a = _model(id: 'a2', nome: 'foto.png', tipo: 'image/png');
      await tester.runAsync(() async {
        await tester.pumpWidget(
          localizedApp(
            home: AttachmentViewerPage(
              attachment: a,
              bytes: Uint8List.fromList([1, 2, 3]),
              controller: controller,
            ),
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pump();
      expect(find.text(L10n.current.attachmentOpenError), findsOneWidget);
      await tester.tap(find.byKey(const Key('attachment-error-open-external')));
      await tester.pump();
      expect(opener.opened.single, ('a2', 3, 'foto.png', 'image/png'));
    });

    group('PDF', () {
      late StreamController<Uint8List> pages;
      final pdf = Uint8List.fromList([0x25, 0x50, 0x44, 0x46, 0x2D]);

      final dpis = <double>[];

      setUp(() {
        pages = StreamController<Uint8List>();
        dpis.clear();
      });
      // Sem `await`: o `done` só é entregue dentro do pump do teste.
      tearDown(() {
        pages.close();
      });

      Widget viewer() => localizedApp(
        home: AttachmentViewerPage(
          attachment: _model(tamanho: pdf.length),
          bytes: pdf,
          controller: controller,
          pdfRenderer: (bytes, dpi) {
            expect(bytes, same(pdf));
            dpis.add(dpi);
            return pages.stream;
          },
        ),
      );

      testWidgets('primeira página aparece antes das demais', (tester) async {
        await tester.pumpWidget(viewer());
        expect(find.text('Carregando páginas…'), findsOneWidget);
        expect(find.byKey(const Key('attachment-viewer-pdf')), findsNothing);

        pages.add(_png); // 1ª página; o stream continua aberto
        await tester.pump();
        expect(find.byKey(const Key('attachment-viewer-pdf')), findsOneWidget);
        expect(find.byType(Image), findsOneWidget);
        expect(find.text('Carregando páginas…'), findsOneWidget);

        pages.add(_png);
        unawaited(pages.close());
        await tester.pump();
        // A 2ª página pode estar abaixo da área visível (lista preguiçosa).
        final list = tester.widget<ListView>(find.byType(ListView));
        expect(
          (list.childrenDelegate as SliverChildBuilderDelegate).childCount,
          2,
        );
        expect(find.text('Carregando páginas…'), findsNothing);
      });

      testWidgets('erro depois de páginas: mantém as páginas e avisa', (
        tester,
      ) async {
        await tester.pumpWidget(viewer());
        pages.add(_png);
        await tester.pump();
        pages.addError(Exception('página corrompida'));
        await tester.pump();
        expect(find.byType(Image), findsOneWidget);
        expect(find.text(L10n.current.attachmentOpenError), findsOneWidget);
        expect(find.text('Carregando páginas…'), findsNothing);
      });

      testWidgets('dpi: 800 de largura a 1× ≈ 193,5; tela densa = 200', (
        tester,
      ) async {
        addTearDown(tester.view.reset);
        tester.view.physicalSize = const Size(800, 600);
        tester.view.devicePixelRatio = 1;
        await tester.pumpWidget(viewer());
        expect(dpis.single, closeTo(800 * 2 / 8.27, 0.01));

        await tester.pumpWidget(const SizedBox());
        pages = StreamController<Uint8List>(); // stream de assinatura única
        tester.view.physicalSize = const Size(1800, 3600); // 600 lógicos a 3×
        tester.view.devicePixelRatio = 3;
        await tester.pumpWidget(viewer());
        expect(dpis.last, 200);

        await tester.pumpWidget(const SizedBox());
        pages = StreamController<Uint8List>(); // stream de assinatura única
        tester.view.physicalSize = const Size(2400, 1200); // 2400 lógicos a 1×
        tester.view.devicePixelRatio = 1;
        await tester.pumpWidget(viewer());
        expect(dpis.last, 200);
      });

      testWidgets(
        'PDF que não renderiza: erro e "Abrir em outro app" com os mesmos bytes',
        (tester) async {
          await tester.pumpWidget(viewer());
          pages.addError(Exception('PDF inválido'));
          await tester.pump();
          expect(find.text(L10n.current.attachmentOpenError), findsOneWidget);
          final button = find.byKey(
            const Key('attachment-error-open-external'),
          );
          expect(button, findsOneWidget);

          await tester.tap(button);
          await tester.pump();
          expect(opener.opened.single, (
            'a1',
            pdf.length,
            'NF 123.pdf',
            'application/pdf',
          ));
        },
      );
    });
  });
}

class _FakeDetailsController extends Fake implements ActiveDetailsController {
  final inits = <String>[];
  @override
  Future<void> init(String id) async => inits.add(id);
}

class _FakeAttachmentsController extends Fake
    implements ActiveAttachmentsController {
  final inits = <String>[];
  @override
  Future<void> init(String id) async => inits.add(id);
}

void pageTests() {
  test('initActiveDetails recarrega a ficha e a aba Arquivos do Ativo', () {
    final details = _FakeDetailsController();
    final attachments = _FakeAttachmentsController();
    initActiveDetails('k1', details: details, attachments: attachments);
    expect(details.inits, ['k1']);
    expect(attachments.inits, ['k1']);
  });
}
