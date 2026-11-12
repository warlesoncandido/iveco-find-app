import 'package:flutter/material.dart';
import 'package:iveco_find/src/core/theme/i_theme.dart';
import 'package:iveco_find/src/core/theme/spaccing.dart';

/// Card de indicador: ícone, título, valor em destaque e um texto de apoio opcional.
class StatCardComponent extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color? color;

  const StatCardComponent({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.subtitle,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final accent = color ?? ITheme.colors.primary;
    return Card(
      color: ITheme.colors.branco,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(md),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: accent.withValues(alpha: 0.15),
              foregroundColor: accent,
              child: Icon(icon),
            ),
            SizedBox(width: md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: ITheme.styles.bodySmallRegular(
                      color: ITheme.colors.cinza90,
                    ),
                  ),
                  SizedBox(height: xs),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(value, style: ITheme.styles.headerBold()),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: xs),
                    Text(
                      subtitle!,
                      style: ITheme.styles.bodyTinyRegular(
                        color: ITheme.colors.cinza110,
                      ),
                    ),
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
