import 'package:flutter/material.dart';
import 'theme_data.dart';

class AppThemes {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppThemeData.primaryColor,
    primarySwatch: AppThemeData.primarySwatch,
    scaffoldBackgroundColor: AppThemeData.lightScaffoldBackground,
    appBarTheme: AppBarTheme(
      backgroundColor: AppThemeData.lightAppBarBackground,
      elevation: 0,
      iconTheme: IconThemeData(color: AppThemeData.lightTextPrimary),
      titleTextStyle: TextStyle(
        color: AppThemeData.lightTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    colorScheme: ColorScheme.light(
      primary: AppThemeData.primaryColor,
      secondary: AppThemeData.pinkColor,
      surface: Colors.white,
      background: AppThemeData.lightScaffoldBackground,
      error: AppThemeData.errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppThemeData.lightTextPrimary,
      onBackground: AppThemeData.lightTextPrimary,
      onError: Colors.white,
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(
        color: AppThemeData.lightTextPrimary,
        fontWeight: FontWeight.bold,
        fontSize: 24,
      ),
      displayMedium: TextStyle(
        color: AppThemeData.lightTextPrimary,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
      displaySmall: TextStyle(
        color: AppThemeData.lightTextPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 18,
      ),
      bodyLarge: TextStyle(
        color: AppThemeData.lightTextPrimary,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        color: AppThemeData.lightTextSecondary,
        fontSize: 14,
      ),
      bodySmall: TextStyle(
        color: AppThemeData.lightTextSecondary,
        fontSize: 12,
      ),
      labelLarge: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppThemeData.lightInputBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppThemeData.lightInputBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppThemeData.lightInputBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppThemeData.primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppThemeData.errorColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppThemeData.errorColor, width: 2),
      ),
      hintStyle: TextStyle(color: AppThemeData.lightTextSecondary),
      labelStyle: TextStyle(
        color: AppThemeData.lightTextSecondary,
        fontWeight: FontWeight.w500,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppThemeData.primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
        minimumSize: Size(double.infinity, 50),
        textStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        padding: EdgeInsets.symmetric(vertical: 14),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppThemeData.lightCardBackground,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: EdgeInsets.zero,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppThemeData.lightBadgeColor,
      labelStyle: TextStyle(
        color: AppThemeData.lightTextPrimary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppThemeData.darkCardBackground,
      contentTextStyle: TextStyle(color: AppThemeData.darkTextPrimary),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: AppThemeData.lightInputBorder,
      thickness: 1,
      space: 1,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppThemeData.primaryColor,
    primarySwatch: AppThemeData.primarySwatch,
    scaffoldBackgroundColor: AppThemeData.darkScaffoldBackground,
    appBarTheme: AppBarTheme(
      backgroundColor: AppThemeData.darkAppBarBackground,
      elevation: 0,
      iconTheme: IconThemeData(color: AppThemeData.darkTextPrimary),
      titleTextStyle: TextStyle(
        color: AppThemeData.darkTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    colorScheme: ColorScheme.dark(
      primary: AppThemeData.primaryColor,
      secondary: AppThemeData.pinkColor,
      surface: AppThemeData.darkCardBackground,
      background: AppThemeData.darkScaffoldBackground,
      error: AppThemeData.errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppThemeData.darkTextPrimary,
      onBackground: AppThemeData.darkTextPrimary,
      onError: Colors.white,
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(
        color: AppThemeData.darkTextPrimary,
        fontWeight: FontWeight.bold,
        fontSize: 24,
      ),
      displayMedium: TextStyle(
        color: AppThemeData.darkTextPrimary,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
      displaySmall: TextStyle(
        color: AppThemeData.darkTextPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 18,
      ),
      bodyLarge: TextStyle(
        color: AppThemeData.darkTextPrimary,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        color: AppThemeData.darkTextSecondary,
        fontSize: 14,
      ),
      bodySmall: TextStyle(
        color: AppThemeData.darkTextSecondary,
        fontSize: 12,
      ),
      labelLarge: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppThemeData.darkInputBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppThemeData.darkInputBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppThemeData.darkInputBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppThemeData.primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppThemeData.errorColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppThemeData.errorColor, width: 2),
      ),
      hintStyle: TextStyle(color: AppThemeData.darkHintText),
      labelStyle: TextStyle(
        color: AppThemeData.darkTextSecondary,
        fontWeight: FontWeight.w500,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppThemeData.primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
        minimumSize: Size(double.infinity, 50),
        textStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        padding: EdgeInsets.symmetric(vertical: 14),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppThemeData.darkCardBackground,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: EdgeInsets.zero,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppThemeData.darkBadgeColor,
      labelStyle: TextStyle(
        color: AppThemeData.darkTextPrimary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppThemeData.darkCardBackground,
      contentTextStyle: TextStyle(color: AppThemeData.darkTextPrimary),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: AppThemeData.darkInputBorder.withOpacity(0.5),
      thickness: 1,
      space: 1,
    ),
  );
}