import 'package:flutter/material.dart';
import 'package:iveco_find/src/core/theme/i_theme.dart';
import 'package:iveco_find/src/core/theme/spaccing.dart';

class BarItem {
  final String label;
  final int value;
  final Color? color;

  const BarItem({required this.label, required this.value, this.color});
}

/// Bloco com título e barras horizontais (proporcionais ao maior valor), feitas só com widgets.
/// Sem itens, ou com todos em 0, mostra "Nenhum ativo cadastrado".
class BarListComponent extends StatelessWidget {
  static const emptyText = 'Nenhum ativo cadastrado';

  final String title;
  final List<BarItem> items;

  const BarListComponent({super.key, required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    final max = items.fold<int>(0, (m, i) => i.value > m ? i.value : m);
    return Card(
      color: ITheme.colors.branco,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: ITheme.styles.bodyBold()),
            SizedBox(height: md),
            if (max == 0)
              Text(
                emptyText,
                style: ITheme.styles.bodySmallRegular(
                  color: ITheme.colors.cinza110,
                ),
              )
            else
              for (final item in items) _Bar(item: item, max: max),
          ],
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final BarItem item;
  final int max;

  const _Bar({required this.item, required this.max});

  @override
  Widget build(BuildContext context) {
    final color = item.color ?? ITheme.colors.primary;
    return Padding(
      padding: EdgeInsets.only(bottom: sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.label,
                  style: ITheme.styles.bodySmallRegular(),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: sm),
              Text('${item.value}', style: ITheme.styles.bodySmallBold()),
            ],
          ),
          SizedBox(height: xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              height: 10,
              color: ITheme.colors.cinza240,
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: item.value / max,
                heightFactor: 1,
                child: ColoredBox(color: color),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
