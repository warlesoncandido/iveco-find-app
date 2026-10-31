import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iveco_find/src/core/injections/injections.dart';
import 'package:iveco_find/src/core/theme/i_theme.dart';
import 'package:iveco_find/src/modules/auth/auth_module.dart';
import 'package:iveco_find/src/modules/home/home_module.dart';
import 'package:iveco_find/src/modules/home/pages/actives/actives_module.dart';
import 'package:iveco_find/src/modules/home/pages/supplier/supplier_module.dart';
import 'package:iveco_find/src/modules/home/pages/types/type_module.dart';

void main() {
  // DEPENDENCIES INJECTION
  Injections.inittialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Iveco Find',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: ITheme.colors.primary,
          foregroundColor: ITheme.colors.background,
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        scaffoldBackgroundColor: ITheme.colors.background,
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: ITheme.colors.primary,
          foregroundColor: ITheme.colors.background,
        ),
      ),
      routerConfig: _router,
    );
  }
}

final _router = GoRouter(
  routes: [authModule, homeModule, activiesModule, typeModule, supplierModule],
);
