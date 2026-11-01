import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iveco_find/src/core/theme/i_theme.dart';
import 'package:iveco_find/src/modules/home/controllers/home_controller.dart';
import 'package:iveco_find/src/shared/utils/helpers/screen_helper.dart';

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
        return Drawer(
          backgroundColor: ITheme.colors.primary,
          child: Column(
            children: [
              Container(
                height: 100,
                color: ITheme.colors.primary,
                child: const Center(
                  child: Text(
                    'Gestão de ativos',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
              IDrawerItem(
                selected: widget.controller.selectedIndex == 0,
                onTap: () {
                  if (ScreenHelper.isMobile(context)) {
                    context.pop();
                  }
                  widget.controller.setSelectedIndex(0);
                },
                title: 'Dashboard',
                icon: Icons.dashboard,
              ),
              IDrawerItem(
                selected: widget.controller.selectedIndex == 1,
                onTap: () {
                  if (ScreenHelper.isMobile(context)) {
                    context.pop();
                  }
                  widget.controller.setSelectedIndex(1);
                },
                title: 'Ativos',
                icon: Icons.inventory,
              ),
              IDrawerItem(
                selected: widget.controller.selectedIndex == 2,
                onTap: () {
                  if (ScreenHelper.isMobile(context)) {
                    context.pop();
                  }
                  widget.controller.setSelectedIndex(2);
                },
                title: 'Relatorios',
                icon: Icons.storage,
              ),
              IDrawerItem(
                selected: widget.controller.selectedIndex == 3,
                onTap: () {
                  if (ScreenHelper.isMobile(context)) {
                    context.pop();
                  }
                  widget.controller.setSelectedIndex(3);
                },
                title: 'Tipos',
                icon: Icons.type_specimen,
              ),
              IDrawerItem(
                selected: widget.controller.selectedIndex == 4,
                onTap: () {
                  if (ScreenHelper.isMobile(context)) {
                    context.pop();
                  }
                  widget.controller.setSelectedIndex(4);
                },
                title: 'Fornecedores',
                icon: Icons.supervised_user_circle_rounded,
              ),
              IDrawerItem(
                selected: widget.controller.selectedIndex == 5,
                onTap: () {
                  if (ScreenHelper.isMobile(context)) {
                    context.pop();
                  }
                  widget.controller.setSelectedIndex(5);
                },
                title: 'Localidades',
                icon: Icons.location_on,
              ),
              if (widget.controller.isAdmin)
                IDrawerItem(
                  selected: widget.controller.selectedIndex == 6,
                  onTap: () {
                    if (ScreenHelper.isMobile(context)) {
                      context.pop();
                    }
                    widget.controller.setSelectedIndex(6);
                  },
                  title: 'Usuários',
                  icon: Icons.manage_accounts,
                ),
              Spacer(),
              IDrawerItem(
                selected: widget.controller.selectedIndex == 20,
                onTap: () => widget.controller.logout(
                  onSuccess: () {
                    context.pop();
                  },
                ),
                title: 'Sair',
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
