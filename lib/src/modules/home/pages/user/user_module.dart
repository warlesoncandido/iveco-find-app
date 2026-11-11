import 'package:go_router/go_router.dart';
import 'package:iveco_find/src/modules/home/pages/user/pages/add_or_edit_user_page.dart';
import 'package:iveco_find/src/modules/home/pages/user/pages/user_page.dart';
import 'package:iveco_find/src/shared/models/user_model.dart';

final userModule = GoRoute(
  path: '/user',
  name: 'user',
  builder: (context, state) => const UserPage(),
  routes: [
    GoRoute(
      name: 'add-or-edit-user',
      path: '/add-or-edit-user',
      builder: (context, state) =>
          AddOrEditUserPage(user: state.extra as UserModel?),
    ),
  ],
);
