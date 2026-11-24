import 'dart:async';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iveco_find/src/core/services/dio_client.dart';
import 'package:iveco_find/src/modules/home/pages/actives/components/active_attachments_tab.dart';
import 'package:iveco_find/src/modules/home/pages/actives/controllers/active_attachments_controller.dart';
import 'package:iveco_find/src/modules/home/pages/actives/controllers/active_details_controller.dart';
import 'package:iveco_find/src/modules/home/pages/actives/pages/active_details_page.dart';
import 'package:iveco_find/src/shared/models/attachment_model.dart';
import 'package:iveco_find/src/shared/repositories/attachment_repository.dart';
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
}) => AttachmentModel.fromJson(_json(id: id, nome: nome, tipo: tipo));

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
    late ActiveAttachmentsController controller;

    setUp(() {
      repository = _FakeRepository()..items = [_model()];
      opener = _FakeOpener();
      controller = ActiveAttachmentsController(
        repository: repository,
        opener: opener,
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

    test('abrir baixa e entrega ao opener com nome e MIME', () async {
      await controller.init('x1');
      await controller.open(
        controller.attachments.first,
        onError: (_) => fail('x'),
      );
      expect(repository.downloads, ['a1']);
      expect(opener.opened.single, ('a1', 4, 'NF 123.pdf', 'application/pdf'));
      expect(controller.openingId, isNull);
    });

    test('abrir sem app compatível avisa o erro', () async {
      await controller.init('x1');
      opener.fail = true;
      String? error;
      await controller.open(
        controller.attachments.first,
        onError: (m) => error = m,
      );
      expect(error, isNotNull);
      expect(controller.openingId, isNull);
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
  });

  group('ActiveAttachmentsTab', () {
    late ActiveAttachmentsController controller;

    setUp(() async {
      controller = ActiveAttachmentsController(
        repository: _FakeRepository()
          ..items = [
            _model(),
            _model(id: 'a2', nome: 'foto.png', tipo: 'image/png'),
          ],
        opener: _FakeOpener(),
      );
      await controller.init('x1');
    });

    Widget app(bool canEdit) => localizedApp(
      home: Scaffold(
        body: ActiveAttachmentsTab(controller: controller, canEdit: canEdit),
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
      expect((controller.opener as _FakeOpener).opened, hasLength(1));
    });

    testWidgets('lista vazia mostra a mensagem', (tester) async {
      controller.attachments = [];
      await tester.pumpWidget(app(true));
      expect(find.text('Nenhum arquivo anexado.'), findsOneWidget);
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
