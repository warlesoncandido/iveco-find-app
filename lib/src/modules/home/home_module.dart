import 'package:go_router/go_router.dart';
import 'package:iveco_find/src/modules/home/pages/home_page.dart';

final homeModule = GoRoute(
  name: '/home',
  path: '/home',
  builder: (context, state) => const HomePage(),
);
