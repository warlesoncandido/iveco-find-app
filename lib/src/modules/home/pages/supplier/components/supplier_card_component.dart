import 'package:flutter/material.dart';
import 'package:iveco_find/src/core/theme/i_theme.dart';
import 'package:iveco_find/src/core/theme/spaccing.dart';
import 'package:iveco_find/src/shared/components/i_tag.dart';
import 'package:iveco_find/src/shared/models/supplier_model.dart';
import 'package:iveco_find/src/shared/utils/formatters/formatters.dart';

class SupplierCardComponent extends StatelessWidget {
  final SupplierModel item;

  /// `null` = sem permissão para editar: o ícone some.
  final Function()? onTap;
  const SupplierCardComponent({
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
                  child: Icon(Icons.business_outlined),
                ),
                SizedBox(width: md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.razaoSocial, style: ITheme.styles.bodyBold()),
                    Text(
                      Formatters.cnpj(item.cnpj),
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
