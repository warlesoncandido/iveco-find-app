import 'package:go_router/go_router.dart';
import 'package:iveco_find/src/modules/home/pages/actives/pages/activ_details_page.dart';
import 'package:iveco_find/src/modules/home/pages/actives/pages/register_activity_page.dart';

final activiesModule = GoRoute(
  path: '/actives',
  name: 'actives',
  builder: (context, state) => const RegisterActivityPage(),
  routes: [
    GoRoute(
      name: 'register-activity',
      path: '/register-activity',
      builder: (context, state) => const RegisterActivityPage(),
    ),
    GoRoute(
      name: 'active-details',
      path: '/active-details',
      builder: (context, state) => const ActivDetailsPage(),
    ),
  ],
);
