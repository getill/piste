import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tp_intro/data/candidature_repository.dart';
import 'package:tp_intro/main.dart';
import 'package:tp_intro/models/candidature.dart';

class RepositoryRetarde extends CandidatureRepository {
  final attente = Completer<void>();
  int appels = 0;

  @override
  Future<void> enregistrer(Candidature candidature) {
    appels++;
    return attente.future;
  }
}

class RepositoryAvecErreur extends CandidatureRepository {
  int appels = 0;

  @override
  Future<void> enregistrer(Candidature candidature) async {
    if (++appels == 1) throw Exception('Échec simulé');
  }

  @override
  Future<void> supprimer(int id) async {
    throw Exception('Échec simulé');
  }
}

Future<void> ouvrirFormulaire(WidgetTester tester) async {
  await tester.tap(find.text('Ajouter'));
  await tester.pumpAndSettle();
}

Future<void> saisir(
  WidgetTester tester,
  String poste,
  String entreprise,
) async {
  await tester.enterText(find.widgetWithText(TextFormField, 'Poste'), poste);
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Entreprise'),
    entreprise,
  );
}

Future<void> enregistrer(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Enregistrer'));
  await tester.tap(find.text('Enregistrer'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'Crée, consulte, modifie puis annule et confirme la suppression',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      expect(find.byType(Card), findsNWidgets(2));
      await ouvrirFormulaire(tester);
      expect(find.text('Nouvelle candidature'), findsOneWidget);
      expect(
        tester
            .widget<TextFormField>(find.byType(TextFormField).first)
            .controller!
            .text,
        isEmpty,
      );
      await saisir(tester, 'Mobile', 'Piste');
      await tester.tap(find.text('Relance (facultative)'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Choisir'));
      await tester.pumpAndSettle();
      await enregistrer(tester);
      expect(find.text('Détail de la candidature'), findsOneWidget);
      expect(find.text('Mobile'), findsOneWidget);
      expect(find.textContaining('Date de candidature :'), findsOneWidget);
      expect(find.text('Relance : Non prévue'), findsNothing);

      await tester.tap(find.text('Modifier'));
      await tester.pumpAndSettle();
      expect(find.text('Mobile'), findsOneWidget);
      expect(find.text('Piste'), findsOneWidget);
      expect(find.byTooltip('Retirer la relance'), findsOneWidget);
      await saisir(tester, 'Mobile senior', 'Piste');
      await tester.tap(find.byType(DropdownButtonFormField<StatutCandidature>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Entretien').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Retirer la relance'));
      await enregistrer(tester);
      expect(find.text('Mobile senior'), findsOneWidget);
      expect(find.text('Statut : Entretien'), findsOneWidget);
      expect(find.text('Relance : Non prévue'), findsOneWidget);

      await tester.tap(find.text('Supprimer'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();
      expect(find.text('Mobile senior'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(Card), findsNWidgets(3));
      await tester.tap(find.text('Mobile senior'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Supprimer'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Supprimer'));
      await tester.pumpAndSettle();
      expect(find.byType(Card), findsNWidgets(2));
      expect(find.text('Mobile senior'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Refuse un formulaire vide ou rempli uniquement d’espaces', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await ouvrirFormulaire(tester);
    await enregistrer(tester);
    expect(find.text('Renseignez le poste.'), findsOneWidget);
    expect(find.text('Renseignez l’entreprise.'), findsOneWidget);
    expect(find.text('Nouvelle candidature'), findsOneWidget);
    await saisir(tester, '   ', '   ');
    await enregistrer(tester);
    expect(find.text('Renseignez le poste.'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(Card), findsNWidgets(2));
  });

  testWidgets('Deux appels rapprochés enregistrent une seule candidature', (
    tester,
  ) async {
    final repository = RepositoryRetarde();
    await tester.pumpWidget(MyApp(repository: repository));
    await ouvrirFormulaire(tester);
    await saisir(tester, 'Mobile', 'Piste');
    final bouton = tester.widget<FilledButton>(find.byType(FilledButton));
    bouton.onPressed!();
    bouton.onPressed!();
    await tester.pump();
    expect(repository.appels, 1);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Nouvelle candidature'), findsOneWidget);
    repository.attente.complete();
    await tester.pumpAndSettle();
    expect(find.text('Détail de la candidature'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(Card), findsNWidgets(3));
  });

  testWidgets('Conserve la saisie après échec et permet de réessayer', (
    tester,
  ) async {
    await tester.pumpWidget(MyApp(repository: RepositoryAvecErreur()));
    await ouvrirFormulaire(tester);
    await saisir(tester, 'Mobile', 'Piste');
    await enregistrer(tester);
    expect(find.text('Nouvelle candidature'), findsOneWidget);
    expect(find.textContaining('votre saisie est conservée'), findsOneWidget);
    expect(find.text('Mobile'), findsOneWidget);
    expect(find.text('Piste'), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNotNull,
    );
    await enregistrer(tester);
    expect(find.text('Détail de la candidature'), findsOneWidget);
    await tester.tap(find.text('Supprimer'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Supprimer'));
    await tester.pumpAndSettle();
    expect(find.text('Suppression impossible. Réessayez.'), findsOneWidget);
    expect(find.text('Mobile'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(Card), findsNWidgets(3));
  });

  testWidgets('Une modification annulée laisse la candidature intacte', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Développeur Flutter junior'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Modifier'));
    await tester.pumpAndSettle();
    await saisir(tester, 'Changement abandonné', 'Autre entreprise');
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Développeur Flutter junior'), findsOneWidget);
    expect(find.text('Atelier Mobile'), findsOneWidget);
    expect(find.text('Changement abandonné'), findsNothing);
  });

  testWidgets('Liste et formulaire restent utilisables sur petit écran', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MyApp());
    expect(tester.takeException(), isNull);
    await ouvrirFormulaire(tester);
    await saisir(tester, 'Mobile', 'Piste');
    await enregistrer(tester);
    expect(find.text('Détail de la candidature'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
