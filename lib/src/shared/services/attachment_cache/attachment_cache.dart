import 'dart:typed_data';

import 'attachment_cache_io.dart'
    if (dart.library.js_interop) 'attachment_cache_web.dart'
    as impl;

/// Cache local do conteúdo dos Anexos, indexado pelo `id` do Anexo (o conteúdo
/// não muda: renomear só troca o nome). Nunca lança: qualquer falha vira "sem
/// cache" e quem chama cai para o download.
abstract class AttachmentCache {
  /// Cache da plataforma: disco no Android/iOS/desktop, memória na web.
  factory AttachmentCache.platform() => impl.createAttachmentCache();

  /// Conteúdo em cache de [id], só se o tamanho bater com [expectedSize]
  /// (`tamanhoBytes`); entrada com tamanho divergente é descartada.
  Future<Uint8List?> get(String id, int expectedSize);

  /// Guarda [bytes] como conteúdo de [id], descartando os acessados há mais
  /// tempo até caber no limite.
  Future<void> put(String id, Uint8List bytes);

  /// Apaga a entrada de [id] (Anexo removido).
  Future<void> remove(String id);
}

/// Cache em memória (web): LRU pela ordem de acesso, limitado a [maxBytes].
class MemoryAttachmentCache implements AttachmentCache {
  final int maxBytes;

  MemoryAttachmentCache({this.maxBytes = 50 * 1024 * 1024});

  /// Mapa literal = `LinkedHashMap`: mantém a ordem de inserção (o 1º é o mais antigo).
  final _entries = <String, Uint8List>{};
  int _total = 0;

  @override
  Future<Uint8List?> get(String id, int expectedSize) async {
    final bytes = _entries.remove(id);
    if (bytes == null) return null;
    if (bytes.length != expectedSize) {
      _total -= bytes.length;
      return null;
    }
    _entries[id] = bytes; // volta para o fim: acessado agora
    return bytes;
  }

  @override
  Future<void> put(String id, Uint8List bytes) async {
    await remove(id);
    if (bytes.length > maxBytes) return;
    while (_entries.isNotEmpty && _total + bytes.length > maxBytes) {
      final oldest = _entries.keys.first;
      _total -= _entries.remove(oldest)!.length;
    }
    _entries[id] = bytes;
    _total += bytes.length;
  }

  @override
  Future<void> remove(String id) async {
    final bytes = _entries.remove(id);
    if (bytes != null) _total -= bytes.length;
  }
}
