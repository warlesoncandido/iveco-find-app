import 'package:flutter/material.dart';
import 'package:iveco_find/l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:iveco_find/src/modules/home/controllers/home_controller.dart';
import 'package:iveco_find/src/shared/enums/permission.dart';
import 'package:go_router/go_router.dart';
import 'package:iveco_find/src/core/theme/spaccing.dart';
import 'package:iveco_find/src/modules/home/pages/supplier/components/supplier_card_component.dart';
import 'package:iveco_find/src/modules/home/pages/supplier/controllers/supplier_controller.dart';
import 'package:iveco_find/src/shared/components/i_pagination.dart';
import 'package:iveco_find/src/shared/components/i_text_field.dart';
import 'package:iveco_find/src/shared/components/i_view.dart';
import 'package:iveco_find/src/shared/utils/behaviour_page.dart';

class SupplierPage extends StatefulWidget {
  const SupplierPage({super.key});

  @override
  State<SupplierPage> createState() => _SupplierPageState();
}

class _SupplierPageState extends State<SupplierPage> {
  final controller = GetIt.instance.get<SupplierController>();
  late final searchController = TextEditingController(text: controller.query);

  /// Botões de cadastrar/editar só para quem tem `cadastros:gerir` (senão a API dá 403).
  bool get _canManage =>
      GetIt.instance.get<HomeController>().can(Permission.cadastrosGerir);

  @override
  void initState() {
    controller.loadSuppliers();
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, value) {
        final l = AppLocalizations.of(context)!;
        // O IView só assume a tela no erro: no loading a busca continua
        // montada (não perde texto/foco a cada recarga).
        return IView(
          behaviourPage: controller.behaviourPage == Behaviour.error
              ? Behaviour.error
              : Behaviour.success,
          onRetry: () => controller.loadSuppliers(),
          floatingActionButton: !_canManage
              ? SizedBox.shrink()
              : FloatingActionButton(
                  onPressed: () async {
                    final result = await context.pushNamed(
                      'add-or-edit-supplier',
                    );
                    if (result == true) {
                      controller.loadSuppliers();
                    }
                  },
                  child: Icon(Icons.add),
                ),
          bottom: controller.pagination != null
              ? IPagination(
                  currentPage: controller.currentPage,
                  totalPage: controller.pagination!.calculateTotalPages,
                  onTapPage: controller.setCurrentPage,
                )
              : SizedBox.shrink(),
          child: Padding(
            padding: EdgeInsets.all(md),
            child: Column(
              spacing: md,
              children: [
                ITextField(
                  label: l.suppliersSearch,
                  controller: searchController,
                  suffixIcon: Icon(Icons.search),
                  maxLines: 1,
                  textInputAction: TextInputAction.search,
                  onChanged: controller.search,
                ),

                Expanded(
                  child: controller.behaviourPage == Behaviour.loading
                      ? Center(child: CircularProgressIndicator())
                      : controller.suppliers.isEmpty
                      ? Center(child: Text(l.suppliersEmpty))
                      : ListView.builder(
                          itemCount: controller.suppliers.length,
                          itemBuilder: (context, index) {
                            final item = controller.suppliers[index];
                            return SupplierCardComponent(
                              item: item,
                              onTap: !_canManage
                                  ? null
                                  : () async {
                                      final result = await context.pushNamed(
                                        'add-or-edit-supplier',
                                        extra: item,
                                      );
                                      if (result == true) {
                                        controller.loadSuppliers();
                                      }
                                    },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
