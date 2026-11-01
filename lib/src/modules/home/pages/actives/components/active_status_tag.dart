import 'package:flutter/material.dart';
import 'package:iveco_find/src/core/theme/i_theme.dart';
import 'package:iveco_find/src/shared/enums/active_status.dart';

class ActiveStatusTag extends StatelessWidget {
  final ActiveStatus status;
  const ActiveStatusTag({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.label,
        style: ITheme.styles.bodyTinyBold(color: status.color),
      ),
    );
  }
}
