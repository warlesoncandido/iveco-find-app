import 'package:flutter/material.dart';
import 'package:iveco_find/src/core/theme/i_theme.dart';
import 'package:iveco_find/src/core/theme/spaccing.dart';
import 'package:iveco_find/src/shared/components/i_tag.dart';
import 'package:iveco_find/src/shared/models/section_model.dart';

class SectionCardComponent extends StatelessWidget {
  final SectionModel item;

  /// `null` = sem permissão para editar: o ícone some.
  final Function()? onTap;
  const SectionCardComponent({
    super.key,
    required this.item,
    required this.onTap,
  });

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
                  child: Icon(Icons.meeting_room),
                ),
                SizedBox(width: md),
                Text(item.nome, style: ITheme.styles.bodyBold()),
              ],
            ),
            InkWell(
              onTap: onTap,
              child: Row(
                children: [
                  ITag(isActive: item.ativo),
                  if (onTap != null) ...[
                    SizedBox(width: md),
                    Icon(Icons.edit, size: 16),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
