import 'package:flutter/foundation.dart';

class PlatformHelper {
  /// Retorna `true` quando o app roda em Android ou iOS.
  ///
  /// Usa [defaultTargetPlatform] em vez de `dart:io` para funcionar também na
  /// web (ex.: navegador de um celular é considerado mobile).
  static bool get isMobile =>
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  /// Retorna `true` quando o app roda em Windows, macOS ou Linux.
  static bool get isDesktop =>
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.linux;

  /// Retorna `true` quando o app roda no navegador.
  static bool get isWeb => kIsWeb;
}
