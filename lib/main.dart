import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'data/candidature_repository.dart';
import 'state/candidature_controller.dart';
import 'ui/accueil_page.dart';
import 'ui/piste_theme.dart';

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
      theme: pisteTheme(),
      home: AccueilPage(controller: _controller),
    );
  }
}
