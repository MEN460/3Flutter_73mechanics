import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    primaryColor: const Color(0xFF1A237E),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF1A237E),
      secondary: Color.fromARGB(255, 1, 26, 22),
      surface: Color.fromARGB(66, 5, 23, 41),
      onPrimary: Color(0xFFFFFFFF),
      onSecondary: Color(0xFF00332C),
      onSurface: Color(0xFF212121),
    ),
    scaffoldBackgroundColor: const Color.fromARGB(48, 2, 28, 32),
    fontFamily: 'Poppins',
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: Color(0xFF1A237E),
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: Color(0xFF263238),
      ),
      bodyLarge: TextStyle(fontSize: 16, height: 1.5, color: Color(0xFF212121)),
      bodyMedium: TextStyle(fontSize: 14, height: 1.5, color: Color(0xFFB0B0B0)),
      labelLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1A237E),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF1A237E), width: 1.2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF90CAF9), width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF1A237E), width: 2.0),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: TextStyle(color: Colors.grey.shade600),
      labelStyle: const TextStyle(color: Color(0xFF1A237E)),
    ),
    cardTheme: CardThemeData(
      elevation: 3,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: const Color(0xFF202124),
      shadowColor: Colors.black26,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: const Color(0xFF1A237E),
      foregroundColor: const Color.fromARGB(255, 3, 36, 49),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    iconTheme: const IconThemeData(color: Color(0xFFE0E0E0)),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color.fromARGB(255, 4, 50, 61),
      elevation: 1,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1A237E),
      ),
      iconTheme: IconThemeData(color: Color(0xFF1A237E)),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    extensions: const <ThemeExtension<dynamic>>[
      AppCustomTheme(
        mechanicColor: Color(0xFF1A237E),
        nonMechanicColor: Color(0xFF388E3C),
        markerShadow: BoxShadow(
          color: Color(0x22000000),
          blurRadius: 10,
          spreadRadius: 1,
        ),
        animationDuration: Duration(milliseconds: 300),
      ),
    ],
  );

  static ThemeData darkTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: const Color(0xFF181A20),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF90CAF9),
      secondary: Color(0xFF00BFA5),
      surface: Color(0xFF23272F),
      onPrimary: Color(0xFF181A20),
      onSecondary: Color(0xFF00BFA5),
      onSurface: Color(0xFFF3F6FB),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: Color(0xFF90CAF9),
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: Color(0xFFF3F6FB),
      ),
      bodyLarge: TextStyle(fontSize: 16, height: 1.5, color: Color(0xFFF3F6FB)),
      labelLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFF90CAF9),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: const Color(0xFF23272F),
      shadowColor: Colors.black45,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF181A20),
      elevation: 2,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Color(0xFF90CAF9),
      ),
      iconTheme: IconThemeData(color: Color(0xFF90CAF9)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF23272F),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF90CAF9), width: 1.2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF90CAF9), width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF90CAF9), width: 2.0),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: const TextStyle(color: Colors.grey),
      labelStyle: const TextStyle(color: Color(0xFF90CAF9)),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: const Color(0xFF90CAF9),
      foregroundColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    iconTheme: const IconThemeData(color: Color(0xFF90CAF9)),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    extensions: const <ThemeExtension<dynamic>>[
      AppCustomTheme(
        mechanicColor: Color(0xFF90CAF9),
        nonMechanicColor: Color(0xFF81C784),
        markerShadow: BoxShadow(
          color: Color(0x44000000),
          blurRadius: 12,
          spreadRadius: 2,
        ),
        animationDuration: Duration(milliseconds: 300),
      ),
    ],
  );
}

class AppCustomTheme extends ThemeExtension<AppCustomTheme> {
  const AppCustomTheme({
    required this.mechanicColor,
    required this.nonMechanicColor,
    required this.markerShadow,
    required this.animationDuration,
  });

  final Color mechanicColor;
  final Color nonMechanicColor;
  final BoxShadow markerShadow;
  final Duration animationDuration;

  @override
  ThemeExtension<AppCustomTheme> copyWith({
    Color? mechanicColor,
    Color? nonMechanicColor,
    BoxShadow? markerShadow,
    Duration? animationDuration,
  }) {
    return AppCustomTheme(
      mechanicColor: mechanicColor ?? this.mechanicColor,
      nonMechanicColor: nonMechanicColor ?? this.nonMechanicColor,
      markerShadow: markerShadow ?? this.markerShadow,
      animationDuration: animationDuration ?? this.animationDuration,
    );
  }

  @override
  ThemeExtension<AppCustomTheme> lerp(
    ThemeExtension<AppCustomTheme>? other,
    double t,
  ) {
    if (other is! AppCustomTheme) return this;

    return AppCustomTheme(
      mechanicColor:
          Color.lerp(mechanicColor, other.mechanicColor, t) ?? mechanicColor,
      nonMechanicColor:
          Color.lerp(nonMechanicColor, other.nonMechanicColor, t) ??
          nonMechanicColor,
      markerShadow:
          BoxShadow.lerp(markerShadow, other.markerShadow, t) ?? markerShadow,
      animationDuration: _lerpDuration(
        animationDuration,
        other.animationDuration,
        t,
      ),
    );
  }

  static Duration _lerpDuration(Duration a, Duration b, double t) {
    return Duration(
      milliseconds:
          (a.inMilliseconds + (b.inMilliseconds - a.inMilliseconds) * t)
              .round(),
    );
  }
}
