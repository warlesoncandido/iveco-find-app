import 'package:flutter/material.dart';
import 'package:iveco_find/src/core/theme/i_theme.dart';

// ignore: must_be_immutable
class IButton extends StatelessWidget {
  final bool? isLoading, isDisabled;

  IButton.primary({
    super.key,
    this.text,
    this.onTap,
    this.isLoading,
    this.isDisabled,
    this.isSimple = false,
  }) : _color = ITheme.colors.primary,
       textColor = ITheme.colors.background;
  IButton.secondary({
    super.key,
    this.text,
    this.onTap,
    this.isLoading,
    this.isDisabled,
    this.isSimple = false,
  }) : _color = ITheme.colors.branco,
       textColor = ITheme.colors.primary;

  final Color? _color;
  final String? text;
  final VoidCallback? onTap;
  final Color? textColor;
  final bool isSimple;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDisabled == true || isLoading == true ? null : onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isDisabled == true || isLoading == true
              ? ITheme.colors.cinza225
              : _color,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: isLoading != null && isLoading == true
            ? CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(ITheme.colors.branco),
              )
            : Text(
                text ?? '',
                style: ITheme.styles.bodyBold(
                  color: isDisabled == true || isLoading == true
                      ? ITheme.colors.cinza225
                      : isSimple
                      ? ITheme.colors.branco
                      : textColor,
                ),
              ),
      ),
    );
  }
}
