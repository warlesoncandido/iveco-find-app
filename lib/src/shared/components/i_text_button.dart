import 'package:flutter/material.dart';
import 'package:iveco_find/src/core/theme/i_theme.dart';

class ITextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  const ITextButton({super.key, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        label,
        style: ITheme.styles.bodyTinyRegular(color: ITheme.colors.primary),
      ),
    );
  }
}
