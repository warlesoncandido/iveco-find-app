import 'package:go_router/go_router.dart';
import 'package:iveco_find/src/modules/auth/pages/auth_page.dart';
import 'package:iveco_find/src/modules/auth/pages/change_password_page.dart';

final authModule = GoRoute(
  path: '/',
  name: '/',
  builder: (context, state) => const AuthPage(),
);

final changePasswordModule = GoRoute(
  path: '/change-password',
  name: 'change-password',
  builder: (context, state) => const ChangePasswordPage(),
);
