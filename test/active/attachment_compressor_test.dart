import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:iveco_find/src/shared/services/attachment_compressor.dart';

/// Imagem com degradê (comprime de forma realista) e um quadrado vermelho no
/// canto superior esquerdo, para conferir a rotação.
img.Image _image(int width, int height) {
  final image = img.Image(width: width, height: height);
  for (final p in image) {
    p
      ..r = (p.x * 255) ~/ width
      ..g = (p.y * 255) ~/ height
      ..b = ((p.x + p.y) * 7) % 256;
  }
  img.fillRect(
    image,
    x1: 0,
    y1: 0,
    x2: 300,
    y2: 300,
    color: img.ColorRgb8(255, 0, 0),
  );
  return image;
}

void main() {
  const compressor = AttachmentCompressor();

  test('foto grande com EXIF: ≤ 2560 px, rotação aplicada, sem EXIF', () {
    final source = _image(4000, 3000);
    source.exif.imageIfd.orientation = 6; // girar 90° no sentido horário
    final original = img.encodeJpg(source, quality: 100);

    final out = AttachmentCompressor.compressSync(original, 'IMG_0001.JPG');

    expect(out.length, lessThan(original.length));
    final decoded = img.decodeJpg(out)!;
    // 4000×3000 deitada vira 3000×4000 em pé e cai para 1920×2560.
    expect(decoded.width, 1920);
    expect(decoded.height, 2560);
    expect(decoded.exif.imageIfd.hasOrientation, isFalse);
    expect(img.decodeJpgExif(out)?.isEmpty ?? true, isTrue);
    // O quadrado vermelho (topo-esquerda) foi para o topo-direita.
    final topRight = decoded.getPixel(decoded.width - 20, 20);
    expect(topRight.r, greaterThan(200));
    expect(topRight.g, lessThan(60));
  });

  test('JPEG pequeno já otimizado: devolve o original', () {
    final original = img.encodeJpg(
      _image(800, 600),
      quality: 50,
      chroma: img.JpegChroma.yuv420,
    );
    final out = AttachmentCompressor.compressSync(original, 'pequeno.jpeg');
    expect(identical(out, original), isTrue);
  });

  test('PNG grande: continua PNG e ≤ 2560 px', () {
    final original = img.encodePng(_image(5000, 3000), level: 1);
    final out = AttachmentCompressor.compressSync(original, 'planta.png');

    expect(out.length, lessThan(original.length));
    expect(img.PngDecoder().isValidFile(out), isTrue);
    final decoded = img.decodePng(out)!;
    expect(decoded.width, 2560);
    expect(decoded.height, 1536);
  });

  test('PNG animado (APNG): devolve o original', () {
    final animated = _image(3000, 2000)..addFrame(_image(3000, 2000));
    final original = img.encodePng(animated, level: 0);
    expect(img.PngDecoder().startDecode(original)!.numFrames, 2);
    final out = AttachmentCompressor.compressSync(original, 'anim.png');
    expect(identical(out, original), isTrue);
  });

  test('bytes inválidos com extensão .jpg: devolve o original', () async {
    final original = Uint8List.fromList(List.generate(500, (i) => i % 256));
    expect(
      identical(AttachmentCompressor.compressSync(original, 'x.jpg'), original),
      isTrue,
    );
    expect(await compressor.compress(original, 'x.jpg'), original);
    final fakeJpeg = Uint8List.fromList([0xff, 0xd8, 0xff, 0xe0, 1, 2, 3]);
    expect(await compressor.compress(fakeJpeg, 'x.jpg'), fakeJpeg);
  });

  test('PDF e WEBP passam intocados', () async {
    final pdf = Uint8List.fromList([0x25, 0x50, 0x44, 0x46, 1, 2, 3]);
    final webp = img.encodePng(_image(3000, 3000), level: 0);
    expect(identical(await compressor.compress(pdf, 'nf.pdf'), pdf), isTrue);
    expect(identical(await compressor.compress(webp, 'f.webp'), webp), isTrue);
    expect(
      identical(AttachmentCompressor.compressSync(pdf, 'nf.PDF'), pdf),
      isTrue,
    );
  });

  test('compress (no isolate) compacta igual à versão síncrona', () async {
    final original = img.encodeJpg(_image(3000, 2000), quality: 100);
    final out = await compressor.compress(original, 'a.jpg');
    expect(out.length, lessThan(original.length));
    expect(img.decodeJpg(out)!.width, 2560);
  });
}
