import 'package:flutter/material.dart';

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
  late final CandidatureController _controller = CandidatureController(
    repository: widget.repository,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Piste',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: AccueilPage(controller: _controller),
    );
  }
}
