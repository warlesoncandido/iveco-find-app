import 'package:flutter/material.dart';
import 'package:iveco_find/src/core/theme/i_theme.dart';

class IDropDown extends StatefulWidget {
  final String? label, errorText;
  final List<String> items;
  final String? value;
  final void Function(dynamic)? onChanged;
  final String? Function(dynamic)? validator;
  final FocusNode? focusNode;
  final EdgeInsetsGeometry? contentPadding;
  const IDropDown({
    super.key,
    this.label,
    this.errorText,
    required this.items,
    this.value,
    this.onChanged,
    this.validator,
    this.focusNode,
    this.contentPadding,
  });

  @override
  State<IDropDown> createState() => _IDropDownState();
}

class _IDropDownState extends State<IDropDown> {
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: widget.value,
      items: widget.items
          .map(
            (e) => DropdownMenuItem<String>(
              value: e,
              child: Text(
                e,
                style: ITheme.styles.bodySmallRegular(color: Colors.black),
              ),
            ),
          )
          .toList(),
      onChanged: widget.onChanged,
      validator: widget.validator,
      focusNode: widget.focusNode,
      decoration: InputDecoration(
        labelText: widget.label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: ITheme.colors.cinza145),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: ITheme.colors.cinza145),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: ITheme.colors.cinza145),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: Colors.red),
        ),
        labelStyle: ITheme.styles.bodySmallRegular(
          color: ITheme.colors.cinza90,
        ),
        contentPadding: widget.contentPadding ?? const EdgeInsets.all(16.0),
        errorText: widget.errorText,
      ),
    );
  }
}
