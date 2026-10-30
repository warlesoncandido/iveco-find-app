import 'package:flutter/material.dart';

class ColorsApp {
  // Brand
  Color primary = Color(0xFF134074);
  Color secundary = Color(0xFF6A0D98);
  Color background = Color(0xFFEFF1F3);
  Color textColor = Color(0xFF000000);

  // Black & White
  Color branco = Color(0xFFFFFFFF);
  Color cinza250 = Color(0xFFFAFAFA);
  Color cinza240 = Color(0xFFF0F0F0);
  Color cinza225 = Color(0xFFE1E1E1);
  Color cinza145 = Color(0xFF919191);
  Color cinza110 = Color(0xFF787878);
  Color cinza90 = Color(0xFF5A5A5A);
  Color cinza60 = Color(0xFF3C3C3C);

  // Suplementares
  Color brilliantRose = Color(0xFFFF6397);
  Color bahamaBlue = Color(0xFF26547C);
  Color alizarin = Color(0xFFED3237);
  Color kellyGreen = Color(0xFF38DE1D);

  ColorsApp({
    Color? primary,
    Color? secundary,
    Color? background,
    Color? textColor,
  }) {
    if (primary != null) this.primary = primary;
    if (secundary != null) this.secundary = secundary;
    if (background != null) this.background = background;
    if (textColor != null) this.textColor = textColor;
  }
}
