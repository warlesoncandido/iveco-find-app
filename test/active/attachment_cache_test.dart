import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:iveco_find/src/shared/services/attachment_cache/attachment_cache.dart';
import 'package:iveco_find/src/shared/services/attachment_cache/attachment_cache_io.dart';

Uint8List _bytes(int length, [int fill = 1]) =>
    Uint8List.fromList(List.filled(length, fill));

void main() {
  group('DiskAttachmentCache', () {
    late Directory tmp;
    late DiskAttachmentCache cache;

    setUp(() async {
      tmp = await Directory.systemTemp.createTemp('attachment_cache_test');
      cache = DiskAttachmentCache(
        maxBytes: 100,
        baseDirectory: () async => tmp,
      );
    });

    tearDown(() async {
      if (await tmp.exists()) await tmp.delete(recursive: true);
    });

    File file(String id) => File('${tmp.path}/anexos_cache/$id');

    test(
      'hit: devolve o que foi guardado, em {cacheDir}/anexos_cache/{id}',
      () async {
        await cache.put('a1', _bytes(10, 7));
        expect(await file('a1').exists(), isTrue);
        expect(await cache.get('a1', 10), _bytes(10, 7));
        expect(await cache.get('outro', 10), isNull);
      },
    );

    test('persiste entre instâncias (reinício do app)', () async {
      await cache.put('a1', _bytes(10));
      final reopened = DiskAttachmentCache(baseDirectory: () async => tmp);
      expect(await reopened.get('a1', 10), hasLength(10));
    });

    test('tamanho divergente: miss e a entrada é descartada', () async {
      await cache.put('a1', _bytes(10));
      expect(await cache.get('a1', 11), isNull);
      expect(await file('a1').exists(), isFalse);
      await cache.put('a1', _bytes(11));
      expect(await cache.get('a1', 11), hasLength(11));
    });

    test('LRU: acima do limite descarta os acessados há mais tempo', () async {
      await cache.put('a', _bytes(40));
      await cache.put('b', _bytes(40));
      // Datas explícitas: "b" é o mais antigo; ler "a" o torna recente.
      await file('a').setLastModified(DateTime(2026, 1, 2));
      await file('b').setLastModified(DateTime(2026, 1, 1));
      expect(await cache.get('a', 40), isNotNull);
      await cache.put('c', _bytes(40));
      expect(await cache.get('b', 40), isNull);
      expect(await cache.get('a', 40), isNotNull);
      expect(await cache.get('c', 40), isNotNull);
    });

    test(
      'pasta anexos/{id}/ do opener no mesmo diretório não atrapalha',
      () async {
        // No Android/iOS/macOS o cache e o temporário são a mesma pasta.
        final opener = Directory('${tmp.path}/anexos/a1');
        await opener.create(recursive: true);
        await File('${opener.path}/foto.png').writeAsBytes(_bytes(90));
        await cache.put('a1', _bytes(40));
        await cache.put('b', _bytes(40));
        await file('a1').setLastModified(DateTime(2026, 1, 1));
        await file('b').setLastModified(DateTime(2026, 1, 2));
        await cache.put('c', _bytes(40)); // força a LRU
        expect(await cache.get('a1', 40), isNull);
        expect(await cache.get('b', 40), isNotNull);
        expect(await cache.get('c', 40), isNotNull);
        // O opener ainda grava o mesmo id sem colidir com o arquivo do cache.
        expect(await File('${opener.path}/foto.png').exists(), isTrue);
        await Directory('${tmp.path}/anexos/b').create(recursive: true);
        expect(await cache.get('b', 40), isNotNull);
      },
    );

    test('arquivo maior que o limite não entra no cache', () async {
      await cache.put('a1', _bytes(101));
      expect(await cache.get('a1', 101), isNull);
    });

    test('remove apaga a entrada', () async {
      await cache.put('a1', _bytes(10));
      await cache.remove('a1');
      expect(await file('a1').exists(), isFalse);
      expect(await cache.get('a1', 10), isNull);
      await cache.remove('inexistente'); // não lança
    });

    test('falha de escrita/leitura nunca lança', () async {
      // `anexos_cache` existe como arquivo: não dá para criar o diretório.
      await File('${tmp.path}/anexos_cache').writeAsString('x');
      await cache.put('a1', _bytes(10));
      expect(await cache.get('a1', 10), isNull);
      await cache.remove('a1');

      final broken = DiskAttachmentCache(
        baseDirectory: () async => throw const FileSystemException('sem disco'),
      );
      await broken.put('a1', _bytes(10));
      expect(await broken.get('a1', 10), isNull);
      await broken.remove('a1');
    });
  });

  group('MemoryAttachmentCache', () {
    late MemoryAttachmentCache cache;

    setUp(() => cache = MemoryAttachmentCache(maxBytes: 100));

    test('hit e miss', () async {
      await cache.put('a1', _bytes(10, 3));
      expect(await cache.get('a1', 10), _bytes(10, 3));
      expect(await cache.get('outro', 10), isNull);
    });

    test('tamanho divergente: miss e a entrada é descartada', () async {
      await cache.put('a1', _bytes(10));
      expect(await cache.get('a1', 11), isNull);
      expect(await cache.get('a1', 10), isNull);
    });

    test('LRU: acima do limite descarta os acessados há mais tempo', () async {
      await cache.put('a', _bytes(40));
      await cache.put('b', _bytes(40));
      expect(await cache.get('a', 40), isNotNull); // "b" vira o mais antigo
      await cache.put('c', _bytes(40));
      expect(await cache.get('b', 40), isNull);
      expect(await cache.get('a', 40), isNotNull);
      expect(await cache.get('c', 40), isNotNull);
    });

    test('substituir não conta o tamanho duas vezes', () async {
      await cache.put('a', _bytes(60));
      await cache.put('a', _bytes(60));
      await cache.put('b', _bytes(40));
      expect(await cache.get('a', 60), isNotNull);
      expect(await cache.get('b', 40), isNotNull);
    });

    test('arquivo maior que o limite não entra; remove apaga', () async {
      await cache.put('grande', _bytes(101));
      expect(await cache.get('grande', 101), isNull);
      await cache.put('a1', _bytes(10));
      await cache.remove('a1');
      expect(await cache.get('a1', 10), isNull);
    });
  });
}
