import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:iveco_find/src/core/theme/i_theme.dart';
import 'package:iveco_find/src/core/theme/spaccing.dart';
import 'package:iveco_find/src/modules/home/pages/dashboard/components/bar_list_component.dart';
import 'package:iveco_find/src/modules/home/pages/dashboard/components/stat_card_component.dart';
import 'package:iveco_find/src/modules/home/pages/dashboard/controllers/dashboard_controller.dart';
import 'package:iveco_find/src/shared/components/i_view.dart';
import 'package:iveco_find/src/shared/enums/active_status.dart';
import 'package:iveco_find/src/shared/utils/helpers/money_helper.dart';

class DashboardPage extends StatefulWidget {
  /// Opcional (testes); por padrão vem do GetIt.
  final DashboardController? controller;

  const DashboardPage({super.key, this.controller});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final DashboardController controller =
      widget.controller ?? GetIt.instance.get<DashboardController>();

  /// Acima desta largura, os cards e os blocos de barras ficam lado a lado.
  static const _wideBreakpoint = 900.0;

  @override
  void initState() {
    super.initState();
    controller.load();
  }

  String _percent(int part, int total) {
    final ratio = total == 0 ? 0 : part / total;
    return NumberFormat.decimalPercentPattern(
      locale: 'pt_BR',
      decimalDigits: 0,
    ).format(ratio);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return IView(
          behaviourPage: controller.behaviourPage,
          onRetry: controller.load,
          bottom: const SizedBox.shrink(),
          floatingActionButton: const SizedBox.shrink(),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= _wideBreakpoint;
              return SingleChildScrollView(
                padding: EdgeInsets.all(md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: md,
                  children: [
                    Text('Dashboard', style: ITheme.styles.titleBold()),
                    _responsive(wide, _cards()),
                    _responsive(wide, _bars()),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// Celular: 1 coluna. Desktop: lado a lado, com a mesma largura.
  Widget _responsive(bool wide, List<Widget> children) {
    if (!wide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: md,
        children: children,
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: md,
      children: [for (final c in children) Expanded(child: c)],
    );
  }

  List<Widget> _cards() {
    final s = controller.summary!;
    return [
      StatCardComponent(
        title: 'Total de ativos',
        value: '${s.total}',
        subtitle: 'Sem baixados',
        icon: Icons.inventory_2_outlined,
      ),
      StatCardComponent(
        title: 'Em uso',
        value: '${s.inUse}',
        subtitle: '${_percent(s.inUse, s.total)} do total',
        icon: Icons.handyman_outlined,
        color: ActiveStatus.emUso.color,
      ),
      StatCardComponent(
        title: 'Valor patrimonial',
        value: MoneyHelper.formatApiMoney(s.totalValue),
        subtitle: '${s.withoutValue} sem valor',
        icon: Icons.attach_money,
        color: ActiveStatus.disponivel.color,
      ),
    ];
  }

  List<Widget> _bars() {
    final s = controller.summary!;
    return [
      BarListComponent(
        title: 'Por status',
        items: [
          for (final status in ActiveStatus.values)
            BarItem(
              label: status.label,
              value: s.byStatus[status] ?? 0,
              color: status.color,
            ),
        ],
      ),
      BarListComponent(
        title: 'Por localidade',
        items: [
          for (final l in controller.locations)
            BarItem(label: l.nome, value: l.quantidade),
        ],
      ),
      BarListComponent(
        title: 'Top 5 por tipo',
        items: [
          for (final t in s.byType)
            BarItem(
              label: t.nome,
              value: t.quantidade,
              color: ITheme.colors.bahamaBlue,
            ),
        ],
      ),
    ];
  }
}
