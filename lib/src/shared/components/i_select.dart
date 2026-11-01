import 'package:flutter/material.dart';
import 'package:iveco_find/src/core/theme/i_theme.dart';

/// Dropdown de objetos (ex.: models da API), com o mesmo visual do `IDropDown`.
class ISelect<T> extends StatelessWidget {
  final String? label;
  final List<T> items;
  final T? value;
  final String Function(T item) itemLabel;
  final bool Function(T a, T b)? compare;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final bool enabled;

  const ISelect({
    super.key,
    this.label,
    required this.items,
    required this.itemLabel,
    this.value,
    this.compare,
    this.onChanged,
    this.validator,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    // O valor precisa ser a mesma instância de um dos itens.
    final selected = value == null
        ? null
        : items.cast<T?>().firstWhere(
            (e) => compare != null ? compare!(e as T, value as T) : e == value,
            orElse: () => null,
          );

    return DropdownButtonFormField<T>(
      initialValue: selected,
      key: ValueKey(selected),
      isExpanded: true,
      items: items
          .map(
            (e) => DropdownMenuItem<T>(
              value: e,
              child: Text(
                itemLabel(e),
                overflow: TextOverflow.ellipsis,
                style: ITheme.styles.bodySmallRegular(color: Colors.black),
              ),
            ),
          )
          .toList(),
      onChanged: enabled ? onChanged : null,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
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
          borderSide: BorderSide(color: ITheme.colors.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: Colors.red),
        ),
        labelStyle: ITheme.styles.bodySmallRegular(
          color: ITheme.colors.cinza90,
        ),
        contentPadding: const EdgeInsets.all(16.0),
      ),
    );
  }
}
