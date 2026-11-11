import 'package:flutter/material.dart';
import 'package:iveco_find/src/core/theme/i_theme.dart';
import 'package:iveco_find/src/modules/public/public_active_page.dart';
import 'package:iveco_find/src/modules/public/public_active_repository.dart';

/// Ponto de entrada web da página pública do Ativo (QR Code: `/a/{id}`).
/// Independente do app: sem router, sem GetIt, sem storage e sem autenticação.
/// Build: `flutter build web -t lib/main_public.dart --base-href /qr/ --no-web-resources-cdn -o build/public_web`.
void main() {
  runApp(PublicApp(id: idFromPath(Uri.base.path)));
}

class PublicApp extends StatelessWidget {
  const PublicApp({super.key, required this.id});

  final String? id;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Iveco Find',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Roboto empacotada no build: nenhuma fonte vem de fonts.gstatic.com.
        fontFamily: 'Roboto',
        appBarTheme: AppBarTheme(
          backgroundColor: ITheme.colors.primary,
          foregroundColor: ITheme.colors.background,
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: ITheme.colors.primary),
        scaffoldBackgroundColor: ITheme.colors.background,
      ),
      home: PublicActivePage(id: id, repository: PublicActiveRepository()),
    );
  }
}
