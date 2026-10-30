import 'package:flutter/material.dart';

class StyleTheme {
  // Big Title - 32PX
  TextStyle bigTitleLight({Color? color}) => TextStyle(fontSize: 32, fontWeight: FontWeight.w300, color: color);
  TextStyle bigTitleRegular({Color? color}) => TextStyle(fontSize: 32, fontWeight: FontWeight.w400, color: color);
  TextStyle bigTitleBold({Color? color}) => TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: color);
  // Title - 24PX
  TextStyle titleLight({Color? color}) => TextStyle(fontSize: 24, fontWeight: FontWeight.w300);
  TextStyle titleRegular({Color? color}) => TextStyle(fontSize: 24, fontWeight: FontWeight.w400);
  TextStyle titleBold({Color? color}) => TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: color);
  // Subtitle - 18PX
  TextStyle subTitleLight({Color? color}) => TextStyle(fontSize: 18, fontWeight: FontWeight.w300, color: color);
  TextStyle subTitleRegular({Color? color}) => TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: color);
  TextStyle subTitleBold({Color? color}) => TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color);
  // Header - 20PX
  TextStyle headerLight({Color? color}) => TextStyle(fontSize: 20, fontWeight: FontWeight.w300, color: color);
  TextStyle headerRegular({Color? color}) => TextStyle(fontSize: 20, fontWeight: FontWeight.w400, color: color);
  TextStyle headerBold({Color? color}) => TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: color);
  // Body - 16PX
  TextStyle bodyLight({Color? color}) => TextStyle(fontSize: 16, fontWeight: FontWeight.w300, color: color);
  TextStyle bodyRegular({Color? color}) => TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: color);
  TextStyle bodyBold({Color? color}) => TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color);
  // Body Small - 14PX
  TextStyle bodySmallLight({Color? color}) => TextStyle(fontSize: 14, fontWeight: FontWeight.w300, color: color);
  TextStyle bodySmallRegular({Color? color}) => TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: color);
  TextStyle bodySmallBold({Color? color}) => TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color);
  // Body Tiny - 12PX
  TextStyle bodyTinyLight({Color? color}) => TextStyle(fontSize: 12, fontWeight: FontWeight.w300, color: color);
  TextStyle bodyTinyRegular({Color? color}) => TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: color);
  TextStyle bodyTinyBold({Color? color}) => TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color);
  // Body Micro - 10PX
  TextStyle bodyMicroLight({Color? color}) => TextStyle(fontSize: 10, fontWeight: FontWeight.w300, color: color);
  TextStyle bodyMicroRegular({Color? color}) => TextStyle(fontSize: 10, fontWeight: FontWeight.w400, color: color);
  TextStyle bodyMicroBold({Color? color}) => TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color);
}
