import 'package:flutter/material.dart';

import '../models/candidature.dart';

const pisteEncre = Color(0xFF0B1D32);
const pistePrimaire = Color(0xFF008F93);
const pisteAction = Color(0xFF007D81);
const pisteAccent = Color(0xFF00BEB4);
const pisteFond = Color(0xFFF7F9FB);
const pisteSecondaire = Color(0xFF5C7188);
const pisteBordure = Color(0xFFE4ECF2);

ThemeData pisteTheme() {
  final base = ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    colorScheme: ColorScheme.fromSeed(seedColor: pistePrimaire).copyWith(
      primary: pisteAction,
      onPrimary: Colors.white,
      surface: Colors.white,
      onSurface: pisteEncre,
      onSurfaceVariant: pisteSecondaire,
      outline: pisteBordure,
    ),
  );
  final contour = OutlineInputBorder(
    borderRadius: BorderRadius.circular(13),
    borderSide: const BorderSide(color: pisteBordure),
  );
  return base.copyWith(
    scaffoldBackgroundColor: pisteFond,
    textTheme: base.textTheme
        .copyWith(
          headlineMedium: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: pisteEncre,
            height: 1.25,
          ),
          headlineSmall: const TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w700,
            color: pisteEncre,
            height: 1.3,
          ),
          titleLarge: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: pisteEncre,
          ),
          titleMedium: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: pisteEncre,
          ),
          bodyMedium: const TextStyle(
            fontSize: 14,
            color: pisteEncre,
            height: 1.5,
          ),
          bodyLarge: const TextStyle(
            fontSize: 15,
            color: pisteEncre,
            height: 1.5,
          ),
        )
        .apply(fontFamily: 'Inter'),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: pisteEncre,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      toolbarHeight: 64,
      titleTextStyle: TextStyle(
        fontFamily: 'Inter',
        fontSize: 19,
        fontWeight: FontWeight.w700,
        color: pisteEncre,
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: pisteBordure),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      border: contour,
      enabledBorder: contour,
      focusedBorder: contour.copyWith(
        borderSide: const BorderSide(color: pistePrimaire, width: 1.5),
      ),
      hintStyle: const TextStyle(
        color: pisteSecondaire,
        fontWeight: FontWeight.w400,
      ),
      labelStyle: const TextStyle(color: pisteSecondaire),
      floatingLabelStyle: const TextStyle(color: pistePrimaire),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
        textStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 50),
        side: const BorderSide(color: pisteBordure),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: pisteAccent,
      foregroundColor: pisteEncre,
      elevation: 2,
      shape: CircleBorder(),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: Colors.white,
      selectedColor: pisteAction,
      side: const BorderSide(color: pisteBordure),
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      showCheckmark: false,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      indicatorColor: pistePrimaire.withValues(alpha: 0.08),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w700
              : FontWeight.w400,
          color: states.contains(WidgetState.selected)
              ? pisteAction
              : pisteSecondaire,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? pisteAction
              : pisteSecondaire,
        ),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    dividerTheme: const DividerThemeData(color: pisteBordure, thickness: 1),
  );
}

extension StatutPresentation on StatutCandidature {
  Color get couleur => switch (this) {
    StatutCandidature.envoyee ||
    StatutCandidature.enCours => const Color(0xFF1467BC),
    StatutCandidature.entretien => const Color(0xFF087552),
    StatutCandidature.offre => const Color(0xFF00756D),
    StatutCandidature.refusee => const Color(0xFFC82C48),
  };
}

class StatutBadge extends StatelessWidget {
  const StatutBadge({super.key, required this.statut});
  final StatutCandidature statut;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: statut.couleur.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(24),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Text(
        statut.libelle,
        style: TextStyle(
          color: statut.couleur,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}
