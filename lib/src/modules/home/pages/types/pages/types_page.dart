import 'package:flutter/material.dart';
import 'package:iveco_find/l10n/app_localizations.dart';
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
  late final searchController = TextEditingController(text: controller.query);

  /// Botões de cadastrar/editar só para quem tem `cadastros:gerir` (senão a API dá 403).
  bool get _canManage =>
      GetIt.instance.get<HomeController>().can(Permission.cadastrosGerir);

  @override
  void initState() {
    controller.loadTypes();
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
                ITextField(
                  label: l.typesSearch,
                  controller: searchController,
                  suffixIcon: Icon(Icons.search),
                  maxLines: 1,
                  textInputAction: TextInputAction.search,
                  onChanged: controller.search,
                ),

                Expanded(
                  child: controller.behaviourPage == Behaviour.loading
                      ? Center(child: CircularProgressIndicator())
                      : controller.types.isEmpty
                      ? Center(child: Text(l.typesEmpty))
                      : ListView.builder(
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
