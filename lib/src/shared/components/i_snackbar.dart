import 'package:flutter/material.dart';

class SnackBarUtils {
  static Future<void> showSnackBarSuccess(
    BuildContext context,
    String message, {
    Color? backgroundColor,
  }) async {
    final snackBar = SnackBar(
      content: Text(message, style: const TextStyle(color: Colors.white)),
      backgroundColor: backgroundColor ?? Colors.green,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static Future<void> showSnackBarError(
    BuildContext context,
    String message, {
    Color? backgroundColor,
  }) async {
    final snackBar = SnackBar(
      content: Text(message, style: const TextStyle(color: Colors.white)),
      backgroundColor: backgroundColor ?? Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> showSnackBarInfo(
    BuildContext context,
    String message, {
    Color? backgroundColor,
  }) async {
    final snackBar = SnackBar(
      content: Text(message, style: const TextStyle(color: Colors.white)),
      backgroundColor: backgroundColor ?? Colors.blue,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
