import 'package:iveco_find/l10n/app_localizations.dart';
import 'package:iveco_find/src/shared/models/ref_model.dart';

/// Categoria do Anexo (`CategoriaAnexo` da API). Obrigatória em todo envio.
enum AttachmentCategory {
  nf('NF'),
  foto('FOTO'),
  manual('MANUAL'),
  certificado('CERTIFICADO'),
  termo('TERMO'),
  laudo('LAUDO');

  final String value;

  const AttachmentCategory(this.value);

  String label(AppLocalizations l) => switch (this) {
    AttachmentCategory.nf => l.attachmentCategoryNf,
    AttachmentCategory.foto => l.attachmentCategoryPhoto,
    AttachmentCategory.manual => l.attachmentCategoryManual,
    AttachmentCategory.certificado => l.attachmentCategoryCertificate,
    AttachmentCategory.termo => l.attachmentCategoryTerm,
    AttachmentCategory.laudo => l.attachmentCategoryReport,
  };

  /// Categoria desconhecida (API mais nova que o app) cai em [manual] em vez de
  /// quebrar a lista inteira.
  static AttachmentCategory fromValue(String value) {
    return AttachmentCategory.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AttachmentCategory.manual,
    );
  }
}

/// Anexo do Ativo (`Anexo` da API). O conteúdo é baixado à parte.
class AttachmentModel {
  final String id;
  final String nome;
  final AttachmentCategory categoria;

  /// MIME detectado pela API: `application/pdf`, `image/jpeg`, `image/png` ou `image/webp`.
  final String tipoConteudo;
  final int tamanhoBytes;
  final DateTime enviadoEm;
  final RefModel enviadoPor;

  AttachmentModel({
    required this.id,
    required this.nome,
    required this.categoria,
    required this.tipoConteudo,
    required this.tamanhoBytes,
    required this.enviadoEm,
    required this.enviadoPor,
  });

  /// Limite do arquivo aceito pela API (20 MB, `LIMITE_ANEXO_BYTES`).
  static const maxBytes = 20 * 1024 * 1024;

  /// Extensões aceitas no seletor de arquivos.
  static const allowedExtensions = ['pdf', 'jpg', 'jpeg', 'png', 'webp'];

  bool get isPdf => tipoConteudo == 'application/pdf';
  bool get isImage => tipoConteudo.startsWith('image/');

  factory AttachmentModel.fromJson(Map<String, dynamic> json) {
    return AttachmentModel(
      id: json['id'] as String,
      nome: json['nome'] as String,
      categoria: AttachmentCategory.fromValue(json['categoria'] as String),
      tipoConteudo: json['tipoConteudo'] as String,
      tamanhoBytes: json['tamanhoBytes'] as int,
      enviadoEm: DateTime.parse(json['enviadoEm'] as String),
      enviadoPor: RefModel.fromJson(json['enviadoPor'] as Map<String, dynamic>),
    );
  }

  /// Tamanho legível: `512 B`, `1,5 KB`, `3,2 MB`.
  static String formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    final kb = bytes / 1024;
    if (kb < 1024) return '${_oneDecimal(kb)} KB';
    return '${_oneDecimal(kb / 1024)} MB';
  }

  static String _oneDecimal(double v) =>
      v.toStringAsFixed(1).replaceAll('.', ',').replaceAll(',0', '');
}
