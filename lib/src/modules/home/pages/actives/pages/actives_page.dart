import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:iveco_find/src/modules/home/controllers/home_controller.dart';
import 'package:iveco_find/src/shared/enums/permission.dart';
import 'package:go_router/go_router.dart';
import 'package:iveco_find/src/core/theme/spaccing.dart';
import 'package:iveco_find/src/modules/home/pages/actives/components/active_card_component.dart';
import 'package:iveco_find/src/modules/home/pages/actives/controllers/actives_controller.dart';
import 'package:iveco_find/src/shared/components/i_pagination.dart';
import 'package:iveco_find/src/shared/components/i_select.dart';
import 'package:iveco_find/src/shared/components/i_text_field.dart';
import 'package:iveco_find/src/shared/enums/active_status.dart';
import 'package:iveco_find/src/shared/pages/error_page.dart';
import 'package:iveco_find/src/shared/utils/behaviour_page.dart';

class ActivesPage extends StatefulWidget {
  const ActivesPage({super.key});

  @override
  State<ActivesPage> createState() => _ActivesPageState();
}

class _ActivesPageState extends State<ActivesPage> {
  final controller = GetIt.instance.get<ActivesController>();

  /// Botões de cadastrar/editar só para quem tem `ativos:escrever` (senão a API dá 403).
  bool get _canManage =>
      GetIt.instance.get<HomeController>().can(Permission.ativosEscrever);

  @override
  void initState() {
    controller.loadActives();
    super.initState();
  }

  Future<void> _openDetails(String id) async {
    await context.pushNamed('active-details', extra: id);
    controller.loadActives();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, value) {
        return Scaffold(
          floatingActionButton: !_canManage
              ? SizedBox.shrink()
              : FloatingActionButton(
                  onPressed: () async {
                    final result = await context.pushNamed(
                      'add-or-edit-active',
                    );
                    if (result is String) {
                      controller.loadActives();
                      _openDetails(result);
                    }
                  },
                  child: Icon(Icons.add),
                ),
          bottomNavigationBar: controller.pagination != null
              ? IPagination(
                  currentPage: controller.currentPage,
                  totalPage: controller.pagination!.calculateTotalPages,
                  onTapPage: controller.setCurrentPage,
                )
              : SizedBox.shrink(),
          body: Padding(
            padding: EdgeInsets.all(md),
            child: Column(
              spacing: md,
              children: [
                Wrap(
                  spacing: md,
                  runSpacing: md,
                  children: [
                    SizedBox(
                      width: 400,
                      child: ITextField(
                        label: 'Pesquisar ativos (nome, códigos, série...)',
                        suffixIcon: Icon(Icons.search),
                        onChanged: controller.search,
                      ),
                    ),
                    SizedBox(
                      width: 220,
                      child: ISelect<ActiveStatus?>(
                        label: 'Status',
                        value: controller.status,
                        items: [null, ...ActiveStatus.values],
                        itemLabel: (item) => item?.label ?? 'Todos',
                        onChanged: controller.changeStatus,
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: switch (controller.behaviourPage) {
                    Behaviour.loading => Center(
                      child: CircularProgressIndicator(),
                    ),
                    Behaviour.error => ErrorPage(
                      onRetry: controller.loadActives,
                    ),
                    Behaviour.success =>
                      controller.actives.isEmpty
                          ? Center(child: Text('Nenhum ativo encontrado.'))
                          : ListView.builder(
                              itemCount: controller.actives.length,
                              itemBuilder: (context, index) {
                                final item = controller.actives[index];
                                return ActiveCardComponent(
                                  item: item,
                                  onTap: () => _openDetails(item.id),
                                );
                              },
                            ),
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
