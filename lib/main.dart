import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'data/candidature_repository.dart';
import 'state/candidature_controller.dart';
import 'ui/accueil_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, this.repository});

  final CandidatureRepository? repository;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final CandidatureRepository _repository;
  late final CandidatureController _controller;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? SqliteCandidatureRepository();
    _controller = CandidatureController(_repository);
    unawaited(_controller.charger());
  }

  @override
  void dispose() {
    _controller.dispose();
    unawaited(_repository.fermer());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Piste',
      locale: const Locale('fr'),
      supportedLocales: const [Locale('fr')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF008F93)),
        scaffoldBackgroundColor: const Color(0xFFF7F9FB),
        appBarTheme: const AppBarTheme(backgroundColor: Colors.white),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      home: AccueilPage(controller: _controller),
    );
  }
}
