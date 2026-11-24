import 'dart:io';
import 'dart:typed_data';

import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

/// Grava em `{temp}/anexos/{id}/{nome}` e abre com o app padrão do sistema.
Future<void> openAttachment(
  String id,
  Uint8List bytes,
  String fileName,
  String mimeType,
) async {
  final safeId = id.replaceAll(RegExp(r'[^A-Za-z0-9-]'), '_');
  final dir = Directory(
    '${(await getTemporaryDirectory()).path}/anexos/$safeId',
  );
  await dir.create(recursive: true);
  final safeName = fileName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
  final file = File('${dir.path}/$safeName');
  await file.writeAsBytes(bytes, flush: true);
  final result = await OpenFilex.open(file.path, type: mimeType);
  if (result.type != ResultType.done) {
    throw Exception(result.message);
  }
}
