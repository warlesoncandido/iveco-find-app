import 'package:flutter/material.dart';
import 'package:iveco_find/src/core/theme/i_theme.dart';

class ITag extends StatelessWidget {
  final bool isActive;
  const ITag({super.key, required this.isActive});

  Color get color {
    if (isActive) {
      return Colors.green;
    }
    return Colors.red;
  }

  String get message {
    if (isActive) {
      return 'Ativo';
    }
    return 'Desativado';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(message, style: ITheme.styles.bodyTinyRegular(color: color)),
    );
  }
}
