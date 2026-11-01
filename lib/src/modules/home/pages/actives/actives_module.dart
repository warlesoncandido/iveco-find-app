import 'package:go_router/go_router.dart';
import 'package:iveco_find/src/modules/home/pages/actives/pages/active_details_page.dart';
import 'package:iveco_find/src/modules/home/pages/actives/pages/actives_page.dart';
import 'package:iveco_find/src/modules/home/pages/actives/pages/add_or_edit_active_page.dart';
import 'package:iveco_find/src/modules/home/pages/actives/pages/move_active_page.dart';
import 'package:iveco_find/src/modules/home/pages/actives/pages/write_off_active_page.dart';
import 'package:iveco_find/src/shared/models/active_model.dart';
import 'package:iveco_find/src/shared/models/valid_movement_model.dart';

final activiesModule = GoRoute(
  path: '/actives',
  name: 'actives',
  builder: (context, state) => const ActivesPage(),
  routes: [
    GoRoute(
      name: 'add-or-edit-active',
      path: '/add-or-edit-active',
      builder: (context, state) =>
          AddOrEditActivePage(active: state.extra as ActiveModel?),
    ),
    GoRoute(
      name: 'active-details',
      path: '/active-details',
      builder: (context, state) => ActiveDetailsPage(id: state.extra as String),
    ),
    GoRoute(
      name: 'move-active',
      path: '/move-active',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return MoveActivePage(
          active: extra['active'] as ActiveModel,
          movements: extra['movements'] as List<ValidMovementModel>,
        );
      },
    ),
    GoRoute(
      name: 'write-off-active',
      path: '/write-off-active',
      builder: (context, state) =>
          WriteOffActivePage(active: state.extra as ActiveModel),
    ),
  ],
);
