import 'package:flutter/material.dart';

abstract final class SoundWaveColors {
  static const background = Color(0xFF0B0D11);
  static const surface = Color(0xFF16191F);
  static const elevated = Color(0xFF20242D);
  static const border = Color(0xFF2B3039);
  static const text = Color(0xFFF5F6FA);
  static const secondary = Color(0xFFA3ADBD);
  static const cyan = Color(0xFF22D3EE);
  static const purple = Color(0xFFD65AF0);
  static const error = Color(0xFFFB7185);
}

abstract final class SoundWaveRadii {
  static const control = 6.0;
  static const card = 6.0;
  static const artwork = 8.0;
  static const dialog = 12.0;
}

ThemeData buildSoundWaveTheme() {
  const controlShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(SoundWaveRadii.control)),
  );
  final scheme =
      ColorScheme.fromSeed(
        seedColor: SoundWaveColors.cyan,
        brightness: Brightness.dark,
      ).copyWith(
        primary: SoundWaveColors.text,
        onPrimary: SoundWaveColors.background,
        secondary: SoundWaveColors.cyan,
        tertiary: SoundWaveColors.purple,
        surface: SoundWaveColors.surface,
        onSurface: SoundWaveColors.text,
        onSurfaceVariant: SoundWaveColors.secondary,
        outline: SoundWaveColors.border,
        error: SoundWaveColors.error,
      );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: SoundWaveColors.background,
    textTheme:
        const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
          headlineMedium: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
          titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(fontSize: 16, height: 1.4),
          bodyMedium: TextStyle(fontSize: 14, height: 1.4),
          bodySmall: TextStyle(fontSize: 12, height: 1.4),
        ).apply(
          bodyColor: SoundWaveColors.text,
          displayColor: SoundWaveColors.text,
        ),
    dividerColor: SoundWaveColors.border,
    tooltipTheme: const TooltipThemeData(
      waitDuration: Duration(milliseconds: 500),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        minimumSize: const Size(48, 48),
        shape: controlShape,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(shape: controlShape),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(shape: controlShape),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(shape: controlShape),
    ),
    chipTheme: const ChipThemeData(shape: controlShape),
    popupMenuTheme: const PopupMenuThemeData(shape: controlShape),
    dialogTheme: const DialogThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(SoundWaveRadii.dialog)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: SoundWaveColors.surface,
      hintStyle: const TextStyle(color: SoundWaveColors.secondary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SoundWaveRadii.control),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SoundWaveRadii.control),
        borderSide: const BorderSide(color: SoundWaveColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SoundWaveRadii.control),
        borderSide: const BorderSide(color: SoundWaveColors.cyan, width: 2),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 80,
      elevation: 0,
      backgroundColor: SoundWaveColors.background,
      indicatorColor: Colors.transparent,
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? SoundWaveColors.text
              : SoundWaveColors.secondary,
          size: 25,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontSize: 12,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w700
              : FontWeight.w400,
          color: states.contains(WidgetState.selected)
              ? SoundWaveColors.text
              : SoundWaveColors.secondary,
        ),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: SoundWaveColors.background,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(SoundWaveRadii.dialog),
        ),
      ),
      modalBarrierColor: Color(0xCC000000),
    ),
  );
}
