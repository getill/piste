import 'package:flutter_test/flutter_test.dart';
import 'package:tp_intro/data/candidature_repository.dart';
import 'package:tp_intro/models/candidature.dart';
import 'package:tp_intro/state/candidature_controller.dart';

class RepositoryEnEchec extends CandidatureRepository {
  @override
  Future<void> enregistrer(Candidature candidature) async {
    throw Exception('Échec simulé');
  }

  @override
  Future<void> supprimer(int id) async {
    throw Exception('Échec simulé');
  }
}

void main() {
  test('Crée, modifie puis supprime et notifie la liste partagée', () async {
    final controller = CandidatureController();
    addTearDown(controller.dispose);
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
    );
    expect(modifiee.id, creee.id);
    expect(modifiee.dateCandidature, creee.dateCandidature);
    expect(controller.candidature(creee.id).dateRelance, relance);
    expect(controller.candidatures.length, 3);
    await controller.supprimer(creee.id);
    expect(controller.candidatures.length, 2);
    expect(notifications, 3);
  });

  test('Un échec du repository ne modifie pas les données', () async {
    final controller = CandidatureController(repository: RepositoryEnEchec());
    addTearDown(controller.dispose);
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

  test('Refuse les champs composés uniquement d’espaces', () async {
    final controller = CandidatureController();
    addTearDown(controller.dispose);
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
}
