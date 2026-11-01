import 'package:flutter/material.dart';
import 'package:iveco_find/src/core/theme/i_theme.dart';
import 'package:iveco_find/src/core/theme/spaccing.dart';
import 'package:iveco_find/src/shared/enums/movement_type.dart';
import 'package:iveco_find/src/shared/models/active_history_model.dart';
import 'package:iveco_find/src/shared/utils/helpers/date_helper.dart';

class ActiveHistoryItem extends StatelessWidget {
  final ActiveHistoryModel item;
  const ActiveHistoryItem({super.key, required this.item});

  IconData get icon {
    return switch (item.tipoMovimentacao) {
      MovementType.entrada => Icons.login,
      MovementType.transferencia => Icons.swap_horiz,
      MovementType.saidaParaUso => Icons.output,
      MovementType.devolucao => Icons.keyboard_return,
      MovementType.envioManutencao => Icons.build,
      MovementType.retornoManutencao => Icons.build_circle,
      MovementType.baixa => Icons.archive,
      null => Icons.edit,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: ITheme.colors.branco,
      child: Padding(
        padding: EdgeInsets.all(md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: ITheme.colors.primary.withValues(alpha: 0.2),
              child: Icon(icon, color: ITheme.colors.primary),
            ),
            SizedBox(width: md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: xs,
                children: [
                  Text(item.title, style: ITheme.styles.bodyBold()),
                  Text(
                    '${DateHelper.formatDateTime(item.ocorridoEm)} · ${item.autor.nome}',
                    style: ITheme.styles.bodySmallLight(
                      color: ITheme.colors.cinza90,
                    ),
                  ),
                  for (final change in item.mudancas)
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${change.label}: ',
                            style: ITheme.styles.bodySmallBold(),
                          ),
                          TextSpan(
                            text:
                                '${change.formattedBefore} → ${change.formattedAfter}',
                            style: ITheme.styles.bodySmallRegular(),
                          ),
                        ],
                      ),
                    ),
                  if (item.observacao != null)
                    Text(
                      'Obs.: ${item.observacao}',
                      style: ITheme.styles.bodySmallRegular(
                        color: ITheme.colors.cinza60,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
