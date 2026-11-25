import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// Compacta as imagens JPEG e PNG dos Anexos antes do envio (melhor esforço).
///
/// Reduz o lado maior para até [maxDimension] px, aplica a rotação do EXIF e
/// recodifica no mesmo formato (JPEG com qualidade [jpegQuality]; PNG sem perda),
/// sem levar os metadados (EXIF/GPS). Devolve o menor entre o original e o
/// compactado e nunca lança: qualquer falha devolve o original. PDF, WEBP e
/// outros formatos passam intocados (o `image` não codifica WEBP).
class AttachmentCompressor {
  const AttachmentCompressor();

  static const maxDimension = 2560;
  static const jpegQuality = 80;

  /// Acima disso nem decodifica (memória): devolve o original.
  static const maxPixels = 50 * 1000 * 1000;

  /// Compacta fora da thread da UI (no mobile/desktop; na web o `compute` roda
  /// na thread principal).
  Future<Uint8List> compress(Uint8List bytes, String fileName) async {
    if (_formatOf(fileName) == null) return bytes;
    try {
      // Na web o `compute` roda na thread principal: deixa a barra de
      // "Preparando" pintar antes de a decodificação travar a UI.
      if (kIsWeb) await Future<void>.delayed(const Duration(milliseconds: 16));
      return await compute(_compressEntry, (bytes, fileName));
    } catch (_) {
      return bytes;
    }
  }

  /// Versão síncrona (é o que roda no isolate); exposta para os testes.
  @visibleForTesting
  static Uint8List compressSync(Uint8List bytes, String fileName) {
    try {
      final format = _formatOf(fileName);
      if (format == null || bytes.isEmpty) return bytes;

      final decoder = format == _Format.jpeg
          ? img.JpegDecoder()
          : img.PngDecoder();
      final info = decoder.startDecode(bytes);
      if (info == null || info.width <= 0 || info.height <= 0) return bytes;
      if (info.width * info.height > maxPixels) return bytes;
      if (info.numFrames > 1) return bytes; // APNG: não perde a animação

      var image = format == _Format.jpeg
          ? img.decodeJpg(bytes, maxPixels: maxPixels)
          : img.decodePng(bytes);
      if (image == null) return bytes;

      // Paleta só redimensiona por "vizinho mais próximo": expande antes.
      if (image.hasPalette) image = image.convert(format: img.Format.uint8);
      image = img.bakeOrientation(image);

      final longest = image.width > image.height ? image.width : image.height;
      if (longest > maxDimension) {
        final landscape = image.width >= image.height;
        image = img.copyResize(
          image,
          width: landscape ? maxDimension : null,
          height: landscape ? null : maxDimension,
          interpolation: img.Interpolation.average,
        );
      }

      // Metadados não vão na versão compactada (a rotação já foi aplicada).
      image
        ..exif = img.ExifData()
        ..textData = null;

      final out = format == _Format.jpeg
          ? img.encodeJpg(
              image,
              quality: jpegQuality,
              chroma: img.JpegChroma.yuv420,
            )
          : img.encodePng(image, level: 9);
      return out.isNotEmpty && out.length < bytes.length ? out : bytes;
    } catch (_) {
      return bytes;
    }
  }

  static _Format? _formatOf(String fileName) {
    final dot = fileName.lastIndexOf('.');
    if (dot < 0) return null;
    return switch (fileName.substring(dot + 1).toLowerCase()) {
      'jpg' || 'jpeg' => _Format.jpeg,
      'png' => _Format.png,
      _ => null,
    };
  }
}

enum _Format { jpeg, png }

Uint8List _compressEntry((Uint8List, String) args) =>
    AttachmentCompressor.compressSync(args.$1, args.$2);
