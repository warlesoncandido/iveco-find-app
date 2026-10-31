import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:iveco_find/src/core/theme/i_theme.dart';
import 'package:iveco_find/src/modules/home/controllers/home_controller.dart';
import 'package:iveco_find/src/modules/home/pages/actives/pages/actives_page.dart';
import 'package:iveco_find/src/modules/home/pages/dashboard/pages/dashboard_page.dart';
import 'package:iveco_find/src/modules/home/pages/reports/pages/reports_page.dart';
import 'package:iveco_find/src/modules/home/pages/supplier/pages/supplier_page.dart';
import 'package:iveco_find/src/modules/home/pages/types/pages/types_page.dart';
import 'package:iveco_find/src/shared/components/i_drawer.dart';
import 'package:iveco_find/src/shared/utils/helpers/screen_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final controller = GetIt.instance.get<HomeController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ScreenHelper.isMobile(context)
          ? AppBar(title: Text('Gestão de ativos'))
          : null,
      drawer: IDrawerComponent(controller: controller),
      body: Row(
        children: [
          if (!ScreenHelper.isMobile(context))
            Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(color: ITheme.colors.primary),
                child: IDrawerComponent(controller: controller),
              ),
            ),
          Expanded(
            flex: 3,
            child: PageView(
              controller: controller.pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                DashboardPage(),
                ActivesPage(),
                ReportsPage(),
                TypesPage(),
                SupplierPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
