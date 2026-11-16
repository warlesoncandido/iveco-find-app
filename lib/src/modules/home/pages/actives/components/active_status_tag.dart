import 'package:flutter/material.dart';
import 'package:iveco_find/l10n/app_localizations.dart';
import 'package:iveco_find/src/core/l10n/locale_controller.dart';
import 'package:iveco_find/src/core/theme/i_theme.dart';
import 'package:iveco_find/src/shared/enums/active_status.dart';

class ActiveStatusTag extends StatelessWidget {
  final ActiveStatus status;
  const ActiveStatusTag({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    // A página pública do QR monta sem os delegates e continua em PT-BR.
    final l = AppLocalizations.of(context) ?? L10n.portuguese;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.label(l),
        style: ITheme.styles.bodyTinyBold(color: status.color),
      ),
    );
  }
}
