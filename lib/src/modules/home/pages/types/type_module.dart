import 'package:go_router/go_router.dart';
import 'package:iveco_find/src/modules/home/pages/types/pages/add_or_edit_type_page.dart';
import 'package:iveco_find/src/modules/home/pages/types/pages/types_page.dart';
import 'package:iveco_find/src/shared/models/type_model.dart';

final typeModule = GoRoute(
  path: '/type',
  name: 'type',
  builder: (context, state) => const TypesPage(),
  routes: [
    GoRoute(
      name: 'add-or-edit-type',
      path: '/add-or-edit-type',
      builder: (context, state) =>
          AddOrEditTypePage(type: state.extra as TypeModel?),
    ),
  ],
);
