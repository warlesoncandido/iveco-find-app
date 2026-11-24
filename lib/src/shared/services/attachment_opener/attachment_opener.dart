import 'dart:typed_data';

import 'attachment_opener_io.dart'
    if (dart.library.js_interop) 'attachment_opener_web.dart'
    as impl;

/// Abre o conteúdo de um Anexo já baixado: no Android/iOS/desktop grava num arquivo
/// temporário e abre com o app padrão; na web abre um blob numa nova aba.
abstract class AttachmentOpener {
  /// [id] do Anexo: separa arquivos temporários de Anexos com o mesmo nome.
  Future<void> open(
    String id,
    Uint8List bytes,
    String fileName,
    String mimeType,
  );
}

class PlatformAttachmentOpener implements AttachmentOpener {
  @override
  Future<void> open(
    String id,
    Uint8List bytes,
    String fileName,
    String mimeType,
  ) => impl.openAttachment(id, bytes, fileName, mimeType);
}
