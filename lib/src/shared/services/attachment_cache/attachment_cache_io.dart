import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

import 'attachment_cache.dart';

AttachmentCache createAttachmentCache() => DiskAttachmentCache();

/// Cache em disco: um arquivo por Anexo em `{cacheDir}/anexos_cache/{id}`, LRU pela
/// data de modificação (atualizada a cada leitura), limitado a [maxBytes].
/// O sistema pode limpar o diretório de cache: o app só perde desempenho.
class DiskAttachmentCache implements AttachmentCache {
  final int maxBytes;
  final Future<Directory> Function() _baseDirectory;

  /// [baseDirectory] substitui o `getApplicationCacheDirectory` (testes).
  DiskAttachmentCache({
    this.maxBytes = 200 * 1024 * 1024,
    Future<Directory> Function()? baseDirectory,
  }) : _baseDirectory = baseDirectory ?? getApplicationCacheDirectory;

  static const _tmpSuffix = '.tmp';

  /// Pasta própria: no Android/iOS/macOS o diretório de cache é o mesmo do
  /// temporário, onde o `AttachmentOpener` cria `anexos/{id}/`.
  static const folder = 'anexos_cache';

  Future<Directory> _dir() async {
    final dir = Directory('${(await _baseDirectory()).path}/$folder');
    await dir.create(recursive: true);
    return dir;
  }

  static String _safe(String id) =>
      id.replaceAll(RegExp(r'[^A-Za-z0-9-]'), '_');

  Future<File> _file(String id) async =>
      File('${(await _dir()).path}/${_safe(id)}');

  @override
  Future<Uint8List?> get(String id, int expectedSize) async {
    try {
      final file = await _file(id);
      if (!await file.exists()) return null;
      if (await file.length() != expectedSize) {
        await _tryDelete(file);
        return null;
      }
      final bytes = await file.readAsBytes();
      if (bytes.length != expectedSize) return null;
      try {
        await file.setLastModified(DateTime.now());
      } catch (_) {
        // Sem a data atualizada a LRU só fica menos precisa.
      }
      return bytes;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> put(String id, Uint8List bytes) async {
    try {
      if (bytes.length > maxBytes) return;
      final file = await _file(id);
      // Grava num temporário e renomeia: um arquivo pela metade nunca vira entrada.
      final tmp = File('${file.path}$_tmpSuffix');
      await tmp.writeAsBytes(bytes, flush: true);
      await tmp.rename(file.path);
      await _evict(keep: file.path);
    } catch (_) {
      // Melhor esforço: sem cache, a próxima abertura baixa de novo.
    }
  }

  @override
  Future<void> remove(String id) async {
    try {
      await _tryDelete(await _file(id));
    } catch (_) {}
  }

  /// Apaga os arquivos acessados há mais tempo até o total caber em [maxBytes];
  /// [keep] (o recém-gravado) nunca sai.
  Future<void> _evict({required String keep}) async {
    final entries = <(File, int, DateTime)>[];
    var total = 0;
    await for (final e in (await _dir()).list(followLinks: false)) {
      if (e is! File) continue;
      try {
        final stat = await e.stat();
        entries.add((e, stat.size, stat.modified));
        total += stat.size;
      } catch (_) {}
    }
    if (total <= maxBytes) return;
    entries.sort((a, b) => a.$3.compareTo(b.$3));
    for (final (file, size, _) in entries) {
      if (total <= maxBytes) break;
      if (file.path == keep) continue;
      if (await _tryDelete(file)) total -= size;
    }
  }

  Future<bool> _tryDelete(File file) async {
    try {
      if (await file.exists()) await file.delete();
      return true;
    } catch (_) {
      return false;
    }
  }
}
