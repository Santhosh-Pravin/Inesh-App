

import 'package:flutter/material.dart';

class AppColors{
  static const Color bgBase = Color(0xFF0D1117);
  static const Color bgCard = Color(0xFF161B22);
  static const Color bgCardHover = Color(0xFF1C2333);
  static const Color bgInput = Color(0xFF161B22);
  static const Color bgChipSel = Color(0xFF1F6FEB);
  static const Color bgChipUnsel = Color(0xFF21262D);
  static const Color border = Color(0xFF30363D);
  static const Color borderFocus = Color(0xFF1F6FEB);
  static const Color online = Color(0xFF22C55E);
  static const Color onlineBg = Color(0xFF14532D);
  static const Color offline = Color(0xFFEF4444);
  static const Color offlineBg = Color(0xFF7F1D1D);
  static const Color textPrimary = Color(0xFFE6EDF3);
  static const Color textSecondary = Color(0xFF8B949E);
  static const Color textMuted = Color(0xFF484F58);
  static const Color accent = Color(0xFF1F6FEB);
  static const Color accentLight = Color(0xFF388BFD);
  static const Color brand = Color(0xFF3A5A40);
  static const Color brandDark = Color(0xFF344E41);
  static const Color brandLight = Color(0xFF588151); 
}

class AppText{
  AppText._();
  static const heading = TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 0.3);
  static const subheading = TextStyle(color: AppColors.textSecondary, fontSize: 12);
  static const cardTitle = TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600);
  static const label = TextStyle(color: AppColors.textSecondary, fontSize: 11);
  static const statValue = TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.bold);
  static const statLabel = TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.8);
  static const badge = TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5);
}

class AppTheme {
  AppTheme._();
  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bgBase,
    colorScheme: const ColorScheme.dark(surface: AppColors.bgBase, primary: AppColors.accent),
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bgCard,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.textPrimary),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.bgCard,
      selectedItemColor: AppColors.accent,
      unselectedItemColor: AppColors.textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: AppColors.bgCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColors.bgCard,
      contentTextStyle: TextStyle(color: AppColors.textPrimary),
      behavior: SnackBarBehavior.floating,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.brand,
        foregroundColor: AppColors.textPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
  );
}