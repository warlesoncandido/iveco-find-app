import 'package:flutter/material.dart';
import 'package:iveco_find/src/core/theme/i_theme.dart';
import 'package:iveco_find/src/core/theme/spaccing.dart';

class ISwitch extends StatelessWidget {
  final Function(bool value)? onChanged;
  final bool value;
  final String label;
  const ISwitch({
    super.key,
    this.onChanged,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Switch(value: value, onChanged: onChanged),
        SizedBox(width: md),
        Text(label, style: ITheme.styles.bodyRegular()),
      ],
    );
  }
}
