import 'package:go_router/go_router.dart';
import 'package:iveco_find/src/modules/home/pages/supplier/pages/add_or_edit_supplier_page.dart';
import 'package:iveco_find/src/modules/home/pages/supplier/pages/supplier_page.dart';
import 'package:iveco_find/src/shared/models/supplier_model.dart';

final supplierModule = GoRoute(
  path: '/supplier',
  name: 'supplier',
  builder: (context, state) => const SupplierPage(),
  routes: [
    GoRoute(
      name: 'add-or-edit-supplier',
      path: '/add-or-edit-supplier',
      builder: (context, state) =>
          AddOrEditSupplierPage(supplier: state.extra as SupplierModel?),
    ),
  ],
);
