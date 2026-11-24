import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Cria um blob com o conteúdo e o abre numa nova aba (PDF e imagens o navegador mostra);
/// se o navegador bloquear a aba, cai para o download pelo `<a download>`.
Future<void> openAttachment(
  String id,
  Uint8List bytes,
  String fileName,
  String mimeType,
) async {
  final blob = web.Blob([bytes.toJS].toJS, web.BlobPropertyBag(type: mimeType));
  final url = web.URL.createObjectURL(blob);
  final opened = web.window.open(url, '_blank');
  if (opened == null) {
    final anchor = web.HTMLAnchorElement()
      ..href = url
      ..download = fileName;
    web.document.body?.append(anchor);
    anchor.click();
    anchor.remove();
  }
  // Dá tempo da aba/download ler o blob antes de liberar a URL.
  Future<void>.delayed(
    const Duration(minutes: 1),
    () => web.URL.revokeObjectURL(url),
  );
}
