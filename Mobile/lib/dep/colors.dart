// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';

//? TColor == Theme Color

Color TColor(BuildContext context, Color lightColor, Color darkColor) {
  final Brightness currentBrightness = MediaQuery.of(context).platformBrightness;
  final bool isDarkMode = currentBrightness == Brightness.dark;

  return isDarkMode ? darkColor : lightColor;
}
