import 'package:flutter/material.dart';
import 'package:iveco_find/src/core/theme/i_theme.dart';
import 'package:iveco_find/src/core/theme/spaccing.dart';
import 'package:iveco_find/src/shared/components/i_tag.dart';
import 'package:iveco_find/src/shared/models/type_model.dart';

class TypeCardComponent extends StatelessWidget {
  final TypeModel item;
  final Function() onTap;
  const TypeCardComponent({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: ITheme.colors.branco,
      child: Padding(
        padding: EdgeInsets.all(md),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: ITheme.colors.primary.withOpacity(0.2),
                  child: Icon(Icons.settings),
                ),
                SizedBox(width: md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.nome, style: ITheme.styles.bodyBold()),
                    Text(
                      'Prefixo: ${item.prefixo}',
                      style: ITheme.styles.bodyLight(
                        color: ITheme.colors.cinza145,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            InkWell(
              onTap: onTap,
              child: Row(
                children: [
                  ITag(isActive: item.ativo),
                  SizedBox(width: md),
                  Icon(Icons.edit, size: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
