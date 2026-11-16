import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iveco_find/l10n/app_localizations.dart';
import 'package:iveco_find/src/core/theme/i_theme.dart';
import 'package:iveco_find/src/modules/home/controllers/home_controller.dart';
import 'package:iveco_find/src/shared/enums/permission.dart';
import 'package:iveco_find/src/shared/utils/helpers/screen_helper.dart';

const _items = [
  (
    index: 0,
    title: _drawerDashboard,
    icon: Icons.dashboard,
    permission: Permission.ativosLer,
  ),
  (
    index: 1,
    title: _drawerActives,
    icon: Icons.inventory,
    permission: Permission.ativosLer,
  ),
  (
    index: 3,
    title: _drawerTypes,
    icon: Icons.type_specimen,
    permission: Permission.cadastrosLer,
  ),
  (
    index: 4,
    title: _drawerSuppliers,
    icon: Icons.supervised_user_circle_rounded,
    permission: Permission.cadastrosLer,
  ),
  (
    index: 5,
    title: _drawerLocations,
    icon: Icons.location_on,
    permission: Permission.cadastrosLer,
  ),
  (
    index: 6,
    title: _drawerUsers,
    icon: Icons.manage_accounts,
    permission: Permission.usuariosGerir,
  ),
];

String _drawerDashboard(AppLocalizations l) => l.drawerDashboard;
String _drawerActives(AppLocalizations l) => l.drawerActives;
String _drawerTypes(AppLocalizations l) => l.drawerTypes;
String _drawerSuppliers(AppLocalizations l) => l.drawerSuppliers;
String _drawerLocations(AppLocalizations l) => l.drawerLocations;
String _drawerUsers(AppLocalizations l) => l.drawerUsers;

/// Índice da página de Configurações no PageView da Home (sem permissão: todos veem).
const settingsPageIndex = 7;

class IDrawerComponent extends StatefulWidget {
  final HomeController controller;
  const IDrawerComponent({super.key, required this.controller});

  @override
  State<IDrawerComponent> createState() => _IDrawerComponentState();
}

class _IDrawerComponentState extends State<IDrawerComponent> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, child) {
        final l = AppLocalizations.of(context)!;
        return Drawer(
          backgroundColor: ITheme.colors.primary,
          child: Column(
            children: [
              Container(
                height: 100,
                color: ITheme.colors.primary,
                child: Center(
                  child: Text(
                    l.appHeader,
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
              // Cada item só aparece para quem tem a permissão de leitura da tela
              // (mesma matriz da API). Os índices seguem as páginas do PageView.
              for (final item in _items)
                if (widget.controller.can(item.permission))
                  IDrawerItem(
                    selected: widget.controller.selectedIndex == item.index,
                    onTap: () {
                      if (ScreenHelper.isMobile(context)) {
                        context.pop();
                      }
                      widget.controller.setSelectedIndex(item.index);
                    },
                    title: item.title(l),
                    icon: item.icon,
                  ),
              Spacer(),
              IDrawerItem(
                selected: widget.controller.selectedIndex == settingsPageIndex,
                onTap: () {
                  if (ScreenHelper.isMobile(context)) {
                    context.pop();
                  }
                  widget.controller.setSelectedIndex(settingsPageIndex);
                },
                title: l.drawerSettings,
                icon: Icons.settings,
              ),
              IDrawerItem(
                selected: widget.controller.selectedIndex == 20,
                onTap: () => widget.controller.logout(
                  onSuccess: () {
                    context.pop();
                  },
                ),
                title: l.commonLogout,
                icon: Icons.exit_to_app,
              ),
            ],
          ),
        );
      },
    );
  }
}

class IDrawerItem extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;
  final String title;
  final IconData icon;
  const IDrawerItem({
    super.key,
    required this.selected,
    required this.onTap,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: selected ? ITheme.colors.background : ITheme.colors.primary,
      child: ListTile(
        leading: Icon(
          icon,
          color: selected ? ITheme.colors.primary : ITheme.colors.background,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: selected ? ITheme.colors.primary : ITheme.colors.background,
          ),
        ),

        onTap: onTap,
      ),
    );
  }
}
