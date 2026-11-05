import 'package:flutter_test/flutter_test.dart';
import 'package:tp_intro/models/candidature.dart';

void main() {
  test('Aller-retour des champs et des dates dans le format SQLite', () {
    final candidature = Candidature(
      id: 42,
      entreprise: "L’atelier d'Emma",
      poste: 'Développeuse Flutter',
      statut: StatutCandidature.entretien,
      notes: 'Préparer le portfolio.',
      lienOffre: 'https://exemple.fr/offre',
      dateCreation: DateTime.utc(2026, 11, 5, 10, 30),
      dateModification: DateTime.utc(2026, 11, 6, 12),
      dateRelance: DateTime(2026, 12, 1),
    );
    final relue = Candidature.fromDatabase(candidature.toDatabase());
    expect(relue.toDatabase(), candidature.toDatabase());
    expect(relue.dateCreation.isUtc, isTrue);
  });

  test('Les champs facultatifs vides redeviennent null', () {
    final candidature = Candidature(
      entreprise: 'Piste',
      poste: 'Mobile',
      statut: StatutCandidature.envoyee,
      dateCreation: DateTime(2026, 11, 5),
    );
    final relue = Candidature.fromDatabase({
      ...candidature.toDatabase(),
      'id': 1,
    });
    expect(relue.notes, isNull);
    expect(relue.lienOffre, isNull);
    expect(relue.dateRelance, isNull);
    expect(relue.dateModification, relue.dateCreation);
  });
}
