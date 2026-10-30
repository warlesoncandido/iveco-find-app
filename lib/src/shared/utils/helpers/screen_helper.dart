// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class ScreenHelper {
  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 600;
}
