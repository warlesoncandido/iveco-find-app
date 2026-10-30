import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iveco_find/src/core/theme/i_theme.dart';

class ITextField extends StatelessWidget {
  final String? label, errorText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int? maxLines;
  final TextInputAction? textInputAction;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final FocusNode? focusNode;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool? enabled, readOnly;
  final TextCapitalization? textCapitalization;
  final TextAlign? textAlign;
  final TextStyle? style;
  final EdgeInsetsGeometry? contentPadding;
  final List<TextInputFormatter>? inputFormatters;
  final Color? color;

  const ITextField({
    super.key,
    this.label,
    this.controller,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.readOnly = false,
    this.maxLines,
    this.textInputAction,
    this.onChanged,
    this.onFieldSubmitted,
    this.focusNode,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled,
    this.textCapitalization,
    this.textAlign,
    this.style,
    this.contentPadding,
    this.inputFormatters,
    this.errorText,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      obscureText: obscureText,
      maxLines: maxLines,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      focusNode: focusNode,
      style: ITheme.styles.bodySmallRegular(
        color: color ?? ITheme.colors.textColor,
      ),
      enabled: enabled,
      readOnly: readOnly!,

      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: ITheme.colors.cinza145),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: ITheme.colors.primary),
        ),
        labelStyle: ITheme.styles.bodySmallRegular(
          color: color ?? ITheme.colors.textColor,
        ),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        contentPadding: contentPadding ?? const EdgeInsets.all(16.0),
        errorText: errorText,
        errorMaxLines: 2,
      ),
    );
  }
}
