import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tp_intro/main.dart';
import 'package:tp_intro/models/candidature.dart';

import 'fake_repository.dart';

Future<void> voir(WidgetTester tester, Finder cible) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
  if (cible.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      cible,
      160,
      scrollable: find
          .descendant(
            of: find.byType(ListView).last,
            matching: find.byType(Scrollable),
          )
          .first,
    );
  } else {
    await tester.ensureVisible(cible);
  }
  await tester.pumpAndSettle();
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
  await voir(tester, find.widgetWithText(TextFormField, 'Poste'));
  await tester.enterText(find.widgetWithText(TextFormField, 'Poste'), poste);
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Entreprise'),
    entreprise,
  );
}

Future<void> enregistrer(WidgetTester tester) async {
  await voir(tester, find.text('Enregistrer'));
  await tester.tap(find.text('Enregistrer'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'Crée, consulte, modifie puis annule et confirme la suppression',
    (tester) async {
      await tester.pumpWidget(
        MyApp(repository: FakeCandidatureRepository(candidaturesDemo())),
      );
      await tester.pumpAndSettle();
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
      await voir(
        tester,
        find.widgetWithText(TextFormField, 'Lien vers l’offre (facultatif)'),
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Lien vers l’offre (facultatif)'),
        'https://exemple.fr/offre',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Notes (facultatives)'),
        'Préparer le portfolio.',
      );
      await voir(tester, find.text('Relance (facultative)'));
      await tester.tap(find.text('Relance (facultative)'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Choisir'));
      await tester.pumpAndSettle();
      await enregistrer(tester);
      expect(find.text('Détail de la candidature'), findsOneWidget);
      expect(find.text('Mobile'), findsOneWidget);
      expect(find.text('https://exemple.fr/offre'), findsOneWidget);
      expect(find.text('Préparer le portfolio.'), findsOneWidget);
      expect(find.textContaining('Date de candidature :'), findsOneWidget);
      expect(find.text('Relance : Non prévue'), findsNothing);

      await voir(tester, find.text('Modifier'));
      await tester.tap(find.text('Modifier'));
      await tester.pumpAndSettle();
      expect(find.text('Mobile'), findsOneWidget);
      expect(find.text('Piste'), findsOneWidget);
      expect(find.byTooltip('Retirer la relance'), findsOneWidget);
      expect(find.text('https://exemple.fr/offre'), findsOneWidget);
      expect(find.text('Préparer le portfolio.'), findsOneWidget);
      await saisir(tester, 'Mobile senior', 'Piste');
      await voir(
        tester,
        find.byType(DropdownButtonFormField<StatutCandidature>),
      );
      await tester.tap(find.byType(DropdownButtonFormField<StatutCandidature>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Entretien').last);
      await tester.pumpAndSettle();
      await voir(tester, find.byTooltip('Retirer la relance'));
      await tester.tap(find.byTooltip('Retirer la relance'));
      await enregistrer(tester);
      expect(find.text('Mobile senior'), findsOneWidget);
      expect(find.text('Statut : Entretien'), findsOneWidget);
      expect(find.text('Relance : Non prévue'), findsOneWidget);

      await voir(tester, find.text('Supprimer'));
      await tester.tap(find.text('Supprimer'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();
      expect(find.text('Mobile senior'), findsOneWidget);
      await tester.tap(find.byType(BackButton));
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
    await tester.pumpWidget(
      MyApp(repository: FakeCandidatureRepository(candidaturesDemo())),
    );
    await tester.pumpAndSettle();
    await ouvrirFormulaire(tester);
    await enregistrer(tester);
    expect(find.text('Renseignez le poste.'), findsOneWidget);
    expect(find.text('Renseignez l’entreprise.'), findsOneWidget);
    expect(find.text('Nouvelle candidature'), findsOneWidget);
    await saisir(tester, '   ', '   ');
    await enregistrer(tester);
    expect(find.text('Renseignez le poste.'), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.byType(Card), findsNWidgets(2));
  });

  testWidgets('Refuse un lien d’offre invalide sans fermer le formulaire', (
    tester,
  ) async {
    await tester.pumpWidget(
      MyApp(repository: FakeCandidatureRepository(candidaturesDemo())),
    );
    await tester.pumpAndSettle();
    await ouvrirFormulaire(tester);
    await saisir(tester, 'Mobile', 'Piste');
    final lien = find.widgetWithText(
      TextFormField,
      'Lien vers l’offre (facultatif)',
    );
    await voir(tester, lien);
    await tester.enterText(lien, 'javascript:alert(1)');
    await enregistrer(tester);
    expect(
      find.text('Utilisez une adresse HTTP ou HTTPS valide.'),
      findsOneWidget,
    );
    expect(find.text('Nouvelle candidature'), findsOneWidget);
  });

  testWidgets('Deux appels rapprochés enregistrent une seule candidature', (
    tester,
  ) async {
    final attente = Completer<void>();
    final repository = FakeCandidatureRepository(candidaturesDemo())
      ..attenteEcriture = attente.future;
    await tester.pumpWidget(MyApp(repository: repository));
    await tester.pumpAndSettle();
    await ouvrirFormulaire(tester);
    await saisir(tester, 'Mobile', 'Piste');
    await voir(tester, find.byType(FilledButton));
    final bouton = tester.widget<FilledButton>(find.byType(FilledButton));
    bouton.onPressed!();
    bouton.onPressed!();
    await tester.pump();
    expect(repository.enregistrements, 1);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Nouvelle candidature'), findsOneWidget);
    attente.complete();
    await tester.pumpAndSettle();
    expect(find.text('Détail de la candidature'), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.byType(Card), findsNWidgets(3));
  });

  testWidgets('Conserve la saisie après échec et permet de réessayer', (
    tester,
  ) async {
    final repository = FakeCandidatureRepository(candidaturesDemo())
      ..echecEcriture = true
      ..echecSuppression = true;
    await tester.pumpWidget(MyApp(repository: repository));
    await tester.pumpAndSettle();
    await ouvrirFormulaire(tester);
    await saisir(tester, 'Mobile', 'Piste');
    await enregistrer(tester);
    expect(find.text('Nouvelle candidature'), findsOneWidget);
    expect(find.textContaining('votre saisie est conservée'), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(find.text('Mobile'), findsOneWidget);
    expect(find.text('Piste'), findsOneWidget);
    await voir(tester, find.byType(FilledButton));
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNotNull,
    );
    repository.echecEcriture = false;
    await enregistrer(tester);
    expect(find.text('Détail de la candidature'), findsOneWidget);
    await tester.tap(find.text('Supprimer'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Supprimer'));
    await tester.pumpAndSettle();
    expect(find.text('Suppression impossible. Réessayez.'), findsOneWidget);
    expect(find.text('Mobile'), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();
    expect(find.byType(Card), findsNWidgets(3));
  });

  testWidgets('Une modification annulée laisse la candidature intacte', (
    tester,
  ) async {
    await tester.pumpWidget(
      MyApp(repository: FakeCandidatureRepository(candidaturesDemo())),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Développeur Flutter junior'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Modifier'));
    await tester.pumpAndSettle();
    await saisir(tester, 'Changement abandonné', 'Autre entreprise');
    await tester.tap(find.byType(BackButton));
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
    await tester.pumpWidget(
      MyApp(repository: FakeCandidatureRepository(candidaturesDemo())),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await ouvrirFormulaire(tester);
    await saisir(tester, 'Mobile', 'Piste');
    await enregistrer(tester);
    expect(find.text('Détail de la candidature'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Affiche le chargement, puis le vide et un bilan à zéro', (
    tester,
  ) async {
    final attente = Completer<void>();
    final repo = FakeCandidatureRepository()..attenteLecture = attente.future;
    await tester.pumpWidget(MyApp(repository: repo));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    attente.complete();
    await tester.pumpAndSettle();
    expect(find.text('Aucune candidature.'), findsOneWidget);
    await tester.tap(find.text('Bilan'));
    await tester.pumpAndSettle();
    expect(find.text('Total : 0'), findsOneWidget);
    for (final indicateur in tester.widgetList<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    )) {
      expect(indicateur.value, 0);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Une lecture échouée propose Réessayer et ne prétend pas être vide',
    (tester) async {
      final repo = FakeCandidatureRepository(candidaturesDemo())
        ..echecLecture = true;
      await tester.pumpWidget(MyApp(repository: repo));
      await tester.pumpAndSettle();
      expect(find.text('Chargement impossible. Réessayez.'), findsOneWidget);
      expect(find.text('Aucune candidature.'), findsNothing);
      expect(find.byType(Card), findsNothing);
      repo.echecLecture = false;
      await tester.tap(find.text('Réessayer'));
      await tester.pumpAndSettle();
      expect(find.byType(Card), findsNWidgets(2));
    },
  );

  testWidgets(
    'Recherche et filtre se combinent, le bilan compte toutes les données',
    (tester) async {
      await tester.pumpWidget(
        MyApp(repository: FakeCandidatureRepository(candidaturesDemo())),
      );
      await tester.pumpAndSettle();
      final recherche = find.widgetWithText(
        TextField,
        'Rechercher une candidature',
      );
      await tester.enterText(recherche, 'WEB');
      await tester.pumpAndSettle();
      expect(find.byType(Card), findsOneWidget);
      await tester.tap(find.widgetWithText(ChoiceChip, 'Envoyée'));
      await tester.pumpAndSettle();
      expect(find.text('Aucun résultat pour ces critères.'), findsOneWidget);
      await tester.tap(find.text('Bilan'));
      await tester.pumpAndSettle();
      expect(find.text('Total : 2'), findsOneWidget);
      final envoyees = find.widgetWithText(ListTile, 'Envoyée');
      final entretiens = find.widgetWithText(ListTile, 'Entretien');
      expect(
        find.descendant(of: envoyees, matching: find.text('1')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: entretiens, matching: find.text('1')),
        findsOneWidget,
      );
      await tester.tap(find.text('Candidatures'));
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(recherche).controller!.text, 'WEB');
      await tester.tap(find.widgetWithText(ChoiceChip, 'Toutes'));
      await tester.pumpAndSettle();
      expect(find.byType(Card), findsOneWidget);
    },
  );

  testWidgets('Conserve la recherche après une écriture et sa relecture', (
    tester,
  ) async {
    await tester.pumpWidget(
      MyApp(repository: FakeCandidatureRepository(candidaturesDemo())),
    );
    await tester.pumpAndSettle();
    final recherche = find.widgetWithText(
      TextField,
      'Rechercher une candidature',
    );
    await tester.enterText(recherche, 'absent');
    await tester.pumpAndSettle();
    await ouvrirFormulaire(tester);
    await saisir(tester, 'Mobile', 'Piste');
    await enregistrer(tester);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(recherche).controller!.text, 'absent');
    expect(find.text('Aucun résultat pour ces critères.'), findsOneWidget);
  });
}
