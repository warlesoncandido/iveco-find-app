import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:iveco_find/src/core/l10n/locale_controller.dart';
import 'package:iveco_find/src/core/l10n/localized_app.dart';
import 'package:iveco_find/src/core/injections/injections.dart';
import 'package:iveco_find/src/core/theme/i_theme.dart';
import 'package:iveco_find/src/modules/auth/auth_module.dart';
import 'package:iveco_find/src/modules/home/home_module.dart';
import 'package:iveco_find/src/modules/home/pages/actives/actives_module.dart';
import 'package:iveco_find/src/modules/home/pages/location/location_module.dart';
import 'package:iveco_find/src/modules/home/pages/supplier/supplier_module.dart';
import 'package:iveco_find/src/modules/home/pages/types/type_module.dart';
import 'package:iveco_find/src/modules/home/pages/user/user_module.dart';
import 'package:iveco_find/src/shared/components/i_snackbar.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // DEPENDENCIES INJECTION
  Injections.inittialized(onSessionExpired: _onSessionExpired);
  // Idioma salvo (ou o do dispositivo) antes do primeiro frame, inclusive no login.
  await GetIt.instance.get<LocaleController>().load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return LocalizedApp(
      controller: GetIt.instance.get<LocaleController>(),
      routerConfig: _router,
      title: 'Iveco Find',
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: ITheme.colors.primary,
          foregroundColor: ITheme.colors.background,
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        scaffoldBackgroundColor: ITheme.colors.background,
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: ITheme.colors.primary,
          foregroundColor: ITheme.colors.background,
        ),
      ),
    );
  }
}

/// Navigator raiz do app: permite navegar e mostrar avisos fora da árvore de widgets.
final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Renovação da sessão recusada (o `auth` salvo já foi removido): volta ao login com aviso.
void _onSessionExpired() {
  _router.goNamed('/');
  final context = rootNavigatorKey.currentContext;
  if (context == null || !context.mounted) return;
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  messenger.hideCurrentSnackBar();
  SnackBarUtils.showSnackBarError(context, L10n.current.sessionExpired);
}

final _router = GoRouter(
  navigatorKey: rootNavigatorKey,
  routes: [
    authModule,
    changePasswordModule,
    homeModule,
    activiesModule,
    typeModule,
    supplierModule,
    locationModule,
    userModule,
  ],
);
