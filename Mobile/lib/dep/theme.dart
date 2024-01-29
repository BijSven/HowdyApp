import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ignore_for_file: prefer_const_literals_to_create_immutables

ThemeData lightTheme = ThemeData(
  primaryColor: const Color.fromARGB(255, 253, 185, 121),
  progressIndicatorTheme: const ProgressIndicatorThemeData(color: Color.fromARGB(255, 238, 224, 98)), colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.deepOrangeAccent),
  hintColor: Colors.black,
  canvasColor: Colors.white,
  scaffoldBackgroundColor: const Color.fromARGB(255, 245, 245, 245),
  bottomAppBarTheme: const BottomAppBarTheme(
    color: Colors.black,
    surfaceTintColor: Colors.white,
    shadowColor: Colors.black,
  ),
  fontFamily: GoogleFonts.josefinSans().fontFamily,
  textTheme: GoogleFonts.josefinSansTextTheme().copyWith(
    bodyMedium: const TextStyle(color: Colors.black),
    titleMedium: const TextStyle(color: Colors.black),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color.fromARGB(255, 223, 132, 47),
    iconTheme: IconThemeData(color: Colors.black),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20.0), // Define the radius for rounded corners
      ),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
        return Colors.orange;
      }),
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(backgroundColor: Colors.orange),
);

ThemeData darkTheme = ThemeData(
  primaryColor: const Color.fromARGB(255, 172, 108, 26),
  progressIndicatorTheme: const ProgressIndicatorThemeData(color: Colors.deepOrangeAccent), colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.deepOrangeAccent),
  hintColor: Colors.white,
  canvasColor: Colors.black,
  scaffoldBackgroundColor: const Color.fromARGB(255, 29, 31, 30),
  bottomAppBarTheme: const BottomAppBarTheme(
    color: Colors.white,
    surfaceTintColor: Colors.black,
    shadowColor: Colors.white,
  ),
  fontFamily: GoogleFonts.josefinSans().fontFamily,
  textTheme: GoogleFonts.josefinSansTextTheme().copyWith(
    bodyMedium: const TextStyle(color: Colors.white),
    titleMedium: const TextStyle(color: Colors.white),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color.fromRGBO(202, 101, 54, 1.0),
    iconTheme: IconThemeData(color: Colors.white),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(15),
        bottomRight: Radius.circular(15)
      ),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
        return Colors.orange;
      }),
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(backgroundColor: Colors.deepOrange),
);
