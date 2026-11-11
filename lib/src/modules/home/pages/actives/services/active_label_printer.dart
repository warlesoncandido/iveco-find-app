import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Etiqueta do Ativo para impressora térmica: 50×30 mm com QR, código interno e nome.
class ActiveLabelPrinter {
  const ActiveLabelPrinter();

  /// Formato da página da etiqueta (50×30 mm, margem de 2 mm).
  static const format = PdfPageFormat(
    50 * PdfPageFormat.mm,
    30 * PdfPageFormat.mm,
    marginAll: 2 * PdfPageFormat.mm,
  );

  /// Limite de caracteres do nome na etiqueta; acima disso vira reticências.
  static const maxNome = 40;

  /// Encurta [nome] com reticências quando não cabe na etiqueta.
  static String truncate(String nome, {int max = maxNome}) {
    final texto = nome.trim();
    if (texto.length <= max) return texto;
    return '${texto.substring(0, max - 3).trimRight()}...';
  }

  /// Gera o PDF vetorial da etiqueta.
  Future<Uint8List> buildPdf({
    required String url,
    required String codigoInterno,
    required String nome,
  }) {
    final doc = pw.Document(title: 'Etiqueta $codigoInterno');
    doc.addPage(
      pw.Page(
        pageFormat: format,
        build: (context) => pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.BarcodeWidget(
              barcode: pw.Barcode.qrCode(),
              data: url,
              width: 26 * PdfPageFormat.mm,
              height: 26 * PdfPageFormat.mm,
            ),
            pw.SizedBox(width: 2 * PdfPageFormat.mm),
            pw.Expanded(
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    codigoInterno,
                    style: pw.TextStyle(
                      fontSize: 7,
                      fontWeight: pw.FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: pw.TextOverflow.clip,
                  ),
                  pw.SizedBox(height: 1 * PdfPageFormat.mm),
                  pw.Text(
                    truncate(nome),
                    style: const pw.TextStyle(fontSize: 6),
                    maxLines: 4,
                    overflow: pw.TextOverflow.clip,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    return doc.save();
  }

  /// Abre a caixa de impressão do sistema com a etiqueta. `false` = cancelada.
  Future<bool> printLabel({
    required String url,
    required String codigoInterno,
    required String nome,
  }) async {
    final bytes = await buildPdf(
      url: url,
      codigoInterno: codigoInterno,
      nome: nome,
    );
    return Printing.layoutPdf(
      onLayout: (_) async => bytes,
      name: 'Etiqueta $codigoInterno',
      format: format,
    );
  }
}
