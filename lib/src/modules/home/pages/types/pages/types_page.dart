import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:iveco_find/src/modules/home/controllers/home_controller.dart';
import 'package:iveco_find/src/shared/enums/permission.dart';
import 'package:go_router/go_router.dart';
import 'package:iveco_find/src/core/theme/spaccing.dart';
import 'package:iveco_find/src/modules/home/pages/types/components/type_card_component.dart';
import 'package:iveco_find/src/modules/home/pages/types/controllers/types_controller.dart';
import 'package:iveco_find/src/shared/components/i_pagination.dart';
import 'package:iveco_find/src/shared/components/i_text_field.dart';
import 'package:iveco_find/src/shared/components/i_view.dart';
import 'package:iveco_find/src/shared/utils/behaviour_page.dart';

class TypesPage extends StatefulWidget {
  const TypesPage({super.key});

  @override
  State<TypesPage> createState() => _TypesPageState();
}

class _TypesPageState extends State<TypesPage> {
  final controller = GetIt.instance.get<TypesController>();

  /// Botões de cadastrar/editar só para quem tem `cadastros:gerir` (senão a API dá 403).
  bool get _canManage =>
      GetIt.instance.get<HomeController>().can(Permission.cadastrosGerir);

  @override
  void initState() {
    controller.loadTypes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, value) {
        if (controller.behaviourPage == Behaviour.loading) {
          return Center(child: CircularProgressIndicator());
        }
        return IView(
          behaviourPage: controller.behaviourPage,
          onRetry: () => controller.loadTypes(),
          floatingActionButton: !_canManage
              ? SizedBox.shrink()
              : FloatingActionButton(
                  onPressed: () async {
                    final result = await context.pushNamed('add-or-edit-type');
                    if (result == true) {
                      controller.loadTypes();
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
                ITextField(label: 'Pesquisar tipo'),

                Expanded(
                  child: ListView.builder(
                    itemCount: controller.types.length,
                    itemBuilder: (context, index) {
                      final item = controller.types[index];
                      return TypeCardComponent(
                        item: item,
                        onTap: !_canManage
                            ? null
                            : () async {
                                final result = await context.pushNamed(
                                  'add-or-edit-type',
                                  extra: item,
                                );
                                if (result == true) {
                                  controller.loadTypes();
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
