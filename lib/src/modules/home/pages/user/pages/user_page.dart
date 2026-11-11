import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:iveco_find/src/core/theme/spaccing.dart';
import 'package:iveco_find/src/modules/home/pages/user/components/user_card_component.dart';
import 'package:iveco_find/src/modules/home/pages/user/controllers/user_controller.dart';
import 'package:iveco_find/src/shared/components/i_pagination.dart';
import 'package:iveco_find/src/shared/components/i_select.dart';
import 'package:iveco_find/src/shared/components/i_text_field.dart';
import 'package:iveco_find/src/shared/components/i_view.dart';
import 'package:iveco_find/src/shared/enums/user_profile.dart';
import 'package:iveco_find/src/shared/models/user_model.dart';
import 'package:iveco_find/src/shared/utils/behaviour_page.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final controller = GetIt.instance.get<UserController>();
  late final searchController = TextEditingController(text: controller.query);

  @override
  void initState() {
    controller.loadUsers();
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _openForm([UserModel? user]) async {
    final result = await context.pushNamed('add-or-edit-user', extra: user);
    if (result == true) {
      controller.loadUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, value) {
        // O IView só assume a tela no erro: no loading os filtros continuam
        // montados (busca não perde texto/foco a cada recarga).
        return IView(
          behaviourPage: controller.behaviourPage == Behaviour.error
              ? Behaviour.error
              : Behaviour.success,
          onRetry: controller.loadUsers,
          floatingActionButton: FloatingActionButton(
            onPressed: () => _openForm(),
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
                Wrap(
                  spacing: md,
                  runSpacing: md,
                  children: [
                    SizedBox(
                      width: 400,
                      child: ITextField(
                        label: 'Pesquisar usuário (nome ou e-mail)',
                        controller: searchController,
                        suffixIcon: Icon(Icons.search),
                        onChanged: controller.search,
                      ),
                    ),
                    SizedBox(
                      width: 220,
                      child: ISelect<UserProfile?>(
                        label: 'Perfil',
                        value: controller.perfil,
                        items: [null, ...UserProfile.values],
                        itemLabel: (item) => item?.label ?? 'Todos',
                        onChanged: controller.changePerfil,
                      ),
                    ),
                    SizedBox(
                      width: 220,
                      child: ISelect<bool?>(
                        label: 'Situação',
                        value: controller.ativo,
                        items: const [null, true, false],
                        itemLabel: (item) => switch (item) {
                          null => 'Todos',
                          true => 'Ativos',
                          false => 'Inativos',
                        },
                        onChanged: controller.changeAtivo,
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: controller.behaviourPage == Behaviour.loading
                      ? Center(child: CircularProgressIndicator())
                      : controller.users.isEmpty
                      ? Center(child: Text('Nenhum usuário encontrado.'))
                      : ListView.builder(
                          itemCount: controller.users.length,
                          itemBuilder: (context, index) {
                            final item = controller.users[index];
                            return UserCardComponent(
                              item: item,
                              onTap: () => _openForm(item),
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
