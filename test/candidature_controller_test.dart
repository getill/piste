import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:tp_intro/models/candidature.dart';
import 'package:tp_intro/state/candidature_controller.dart';

import 'fake_repository.dart';

void main() {
  test('Crée, modifie puis supprime et notifie la liste partagée', () async {
    final controller = CandidatureController(
      FakeCandidatureRepository(candidaturesDemo()),
    );
    addTearDown(controller.dispose);
    await controller.charger();
    var notifications = 0;
    controller.addListener(() => notifications++);
    final creee = await controller.enregistrer(
      poste: '  Développeur  ',
      entreprise: '  Piste  ',
      statut: StatutCandidature.envoyee,
    );
    expect(controller.candidatures.length, 3);
    expect(creee.poste, 'Développeur');
    expect(creee.entreprise, 'Piste');
    final relance = DateTime(2026, 12, 1);
    final modifiee = await controller.enregistrer(
      initiale: creee,
      poste: 'Développeur mobile',
      entreprise: 'Piste',
      statut: StatutCandidature.entretien,
      dateRelance: relance,
      lienOffre: ' https://exemple.fr/offre ',
      notes: ' Préparer le portfolio. ',
    );
    expect(modifiee.id, creee.id);
    expect(modifiee.lienOffre, 'https://exemple.fr/offre');
    expect(modifiee.notes, 'Préparer le portfolio.');
    expect(modifiee.dateModification.isBefore(creee.dateModification), isFalse);
    expect(modifiee.dateCreation, creee.dateCreation);
    expect(controller.candidature(creee.id!).dateRelance, relance);
    expect(controller.candidatures.length, 3);
    await controller.supprimer(creee.id!);
    expect(controller.candidatures.length, 2);
    expect(notifications, 6);
  });

  test('Un échec du repository ne modifie pas les données', () async {
    final controller = CandidatureController(
      FakeCandidatureRepository(candidaturesDemo())
        ..echecEcriture = true
        ..echecSuppression = true,
    );
    addTearDown(controller.dispose);
    await controller.charger();
    await expectLater(
      controller.enregistrer(
        poste: 'Mobile',
        entreprise: 'Piste',
        statut: StatutCandidature.envoyee,
      ),
      throwsException,
    );
    await expectLater(controller.supprimer(1), throwsException);
    expect(controller.candidatures.length, 2);
  });

  test('Valide le lien optionnel avant la sauvegarde', () async {
    expect(Candidature.lienOffreValide(null), isTrue);
    expect(Candidature.lienOffreValide(''), isTrue);
    expect(Candidature.lienOffreValide('https://exemple.fr/offre'), isTrue);
    expect(Candidature.lienOffreValide('https://'), isFalse);
    final controller = CandidatureController(
      FakeCandidatureRepository(candidaturesDemo()),
    );
    addTearDown(controller.dispose);
    await controller.charger();
    await expectLater(
      controller.enregistrer(
        poste: 'Mobile',
        entreprise: 'Piste',
        statut: StatutCandidature.envoyee,
        lienOffre: 'javascript:alert(1)',
      ),
      throwsArgumentError,
    );
    final creee = await controller.enregistrer(
      poste: 'Mobile',
      entreprise: 'Piste',
      statut: StatutCandidature.offre,
    );
    expect(creee.dateCreation, creee.dateModification);
    expect(controller.candidatures.length, 3);
  });

  test('Refuse les champs composés uniquement d’espaces', () async {
    final controller = CandidatureController(
      FakeCandidatureRepository(candidaturesDemo()),
    );
    addTearDown(controller.dispose);
    await controller.charger();
    await expectLater(
      controller.enregistrer(
        poste: '   ',
        entreprise: 'Piste',
        statut: StatutCandidature.envoyee,
      ),
      throwsArgumentError,
    );
    expect(controller.candidatures.length, 2);
  });
  test(
    'Distingue le chargement, le vide, l’erreur et la réussite après retry',
    () async {
      final attente = Completer<void>();
      final repo = FakeCandidatureRepository()..attenteLecture = attente.future;
      final controller = CandidatureController(repo);
      addTearDown(controller.dispose);
      final chargement = controller.charger();
      expect(controller.etat, EtatChargement.loading);
      expect(controller.occupe, isTrue);
      attente.complete();
      await chargement;
      expect(controller.etat, EtatChargement.empty);
      repo.echecLecture = true;
      await controller.charger();
      expect(controller.etat, EtatChargement.error);
      expect(controller.messageErreur, isNotNull);
      repo.echecLecture = false;
      await controller.charger();
      expect(controller.etat, EtatChargement.empty);
      await controller.enregistrer(
        poste: 'Mobile',
        entreprise: 'Piste',
        statut: StatutCandidature.envoyee,
      );
      expect(controller.etat, EtatChargement.success);
    },
  );

  test('Combine recherche et statut sans modifier la liste complète', () async {
    final controller = CandidatureController(
      FakeCandidatureRepository(candidaturesDemo()),
    );
    addTearDown(controller.dispose);
    await controller.charger();
    controller.rechercher('  MOBILE  ');
    expect(controller.visibles.single.entreprise, 'Atelier Mobile');
    controller.filtrer(StatutCandidature.entretien);
    expect(controller.visibles, isEmpty);
    expect(controller.candidatures.length, 2);
    controller.rechercher('WEB');
    expect(controller.visibles.single.entreprise, 'Studio Numérique');
    controller.filtrer(null);
    controller.rechercher('');
    expect(controller.visibles.length, 2);
  });

  test(
    'Une relecture échouée après écriture ne fait pas répéter la création',
    () async {
      final repo = FakeCandidatureRepository();
      final controller = CandidatureController(repo);
      addTearDown(controller.dispose);
      await controller.charger();
      repo.echecLecture = true;
      final enregistree = await controller.enregistrer(
        poste: 'Mobile',
        entreprise: 'Piste',
        statut: StatutCandidature.envoyee,
      );
      expect(enregistree.id, isNotNull);
      expect(controller.etat, EtatChargement.error);
      expect(controller.messageErreur, contains('enregistrée'));
      repo.echecLecture = false;
      await controller.charger();
      expect(controller.candidatures.single.id, enregistree.id);
      expect(repo.enregistrements, 1);
    },
  );

  test(
    'Bloque deux mutations simultanées et ne notifie pas après dispose',
    () async {
      final attente = Completer<void>();
      final repo = FakeCandidatureRepository()
        ..attenteEcriture = attente.future;
      final controller = CandidatureController(repo);
      await controller.charger();
      final creation = controller.enregistrer(
        poste: 'Mobile',
        entreprise: 'Piste',
        statut: StatutCandidature.envoyee,
      );
      await expectLater(
        controller.enregistrer(
          poste: 'Double',
          entreprise: 'Piste',
          statut: StatutCandidature.envoyee,
        ),
        throwsStateError,
      );
      controller.dispose();
      attente.complete();
      expect((await creation).id, isNotNull);
      expect(repo.enregistrements, 1);
    },
  );
}
