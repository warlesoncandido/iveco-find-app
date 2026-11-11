/// URL pública do Ativo gravada no QR Code: `{PUBLIC_URL}/a/{id}`.
///
/// `PUBLIC_URL` vem de `--dart-define=PUBLIC_URL`; ausente, cai no `BASE_URL`.
class PublicUrl {
  static const _publicUrl = String.fromEnvironment('PUBLIC_URL');
  static const _baseUrl = String.fromEnvironment('BASE_URL');

  /// Monta a URL do Ativo. [publicUrl] e [baseUrl] existem para teste; por padrão
  /// usam os dart-defines.
  static String ativo(
    String id, {
    String publicUrl = _publicUrl,
    String baseUrl = _baseUrl,
  }) {
    final origem = publicUrl.trim().isNotEmpty ? publicUrl.trim() : baseUrl.trim();
    final semBarra = origem.replaceAll(RegExp(r'/+$'), '');
    return '$semBarra/a/${Uri.encodeComponent(id)}';
  }
}
