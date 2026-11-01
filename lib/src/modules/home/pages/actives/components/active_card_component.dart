import 'package:flutter/material.dart';
import 'package:iveco_find/src/core/theme/i_theme.dart';
import 'package:iveco_find/src/core/theme/spaccing.dart';
import 'package:iveco_find/src/modules/home/pages/actives/components/active_status_tag.dart';
import 'package:iveco_find/src/shared/models/active_summary_model.dart';

class ActiveCardComponent extends StatelessWidget {
  final ActiveSummaryModel item;
  final Function() onTap;
  const ActiveCardComponent({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: ITheme.colors.branco,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(md),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: ITheme.colors.primary.withValues(alpha: 0.2),
                child: Icon(Icons.inventory),
              ),
              SizedBox(width: md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.nome,
                      style: ITheme.styles.bodyBold(),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${item.codigoInterno} · ${item.tipoAtivo.nome}',
                      style: ITheme.styles.bodyLight(
                        color: ITheme.colors.cinza145,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${item.setor.nome} (${item.localidade.nome})'
                      '${item.responsavel != null ? ' · ${item.responsavel}' : ''}',
                      style: ITheme.styles.bodySmallLight(
                        color: ITheme.colors.cinza145,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: md),
              ActiveStatusTag(status: item.status),
              SizedBox(width: md),
              Icon(Icons.chevron_right, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
