import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'package:tp_intro/data/candidature_repository.dart';
import 'package:tp_intro/models/candidature.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late String chemin;
  late SqliteCandidatureRepository repository;

  setUp(() async {
    chemin = path.join(await getDatabasesPath(), 'piste_recette_test.db');
    await deleteDatabase(chemin);
    repository = SqliteCandidatureRepository(chemin: chemin);
  });

  tearDown(() async {
    await repository.fermer();
    await deleteDatabase(chemin);
  });

  testWidgets(
    'SQLite conserve création, édition et suppression après réouverture',
    (tester) async {
      expect(await repository.toutes(), isEmpty);
      final dateCreation = DateTime(2026, 11, 5);
      final creee = await repository.enregistrer(
        Candidature(
          entreprise: "L'atelier",
          poste: "Mobile'); DROP TABLE candidatures; --",
          statut: StatutCandidature.envoyee,
          dateCreation: dateCreation,
        ),
      );
      expect(creee.id, isNotNull);
      await repository.fermer();
      repository = SqliteCandidatureRepository(chemin: chemin);
      final relue = (await repository.toutes()).single;
      expect(relue.id, creee.id);
      expect(relue.poste, creee.poste);
      expect(relue.entreprise, "L'atelier");
      final relance = DateTime(2026, 12, 1);
      final modification = DateTime(2026, 11, 6, 10);
      await repository.enregistrer(
        Candidature(
          id: relue.id,
          entreprise: relue.entreprise,
          poste: 'Mobile senior',
          statut: StatutCandidature.entretien,
          dateCreation: relue.dateCreation,
          dateModification: modification,
          dateRelance: relance,
          notes: 'Préparer le portfolio.',
          lienOffre: 'https://exemple.fr/offre',
        ),
      );
      await repository.fermer();
      repository = SqliteCandidatureRepository(chemin: chemin);
      final modifiee = (await repository.toutes()).single;
      expect(modifiee.id, creee.id);
      expect(modifiee.poste, 'Mobile senior');
      expect(modifiee.statut, StatutCandidature.entretien);
      expect(modifiee.dateCreation, dateCreation);
      expect(modifiee.dateModification, modification);
      expect(modifiee.dateRelance, relance);
      expect(modifiee.notes, 'Préparer le portfolio.');
      expect(modifiee.lienOffre, 'https://exemple.fr/offre');
      await repository.supprimer(modifiee.id!);
      await repository.fermer();
      repository = SqliteCandidatureRepository(chemin: chemin);
      expect(await repository.toutes(), isEmpty);
    },
  );

  testWidgets(
    'La migration v1 vers v2 conserve les données et complète la date',
    (tester) async {
      final ancienne = await openDatabase(
        chemin,
        version: 1,
        onCreate: (db, version) => db.execute('''
        CREATE TABLE candidatures (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          entreprise TEXT NOT NULL,
          poste TEXT NOT NULL,
          status TEXT NOT NULL,
          notes TEXT NOT NULL,
          url TEXT NOT NULL,
          date_creation TEXT NOT NULL,
          prochaine_relance TEXT
        )
      '''),
      );
      final date = DateTime(2026, 10, 14);
      final valeurs = Candidature(
        id: 7,
        entreprise: 'Ancienne entreprise',
        poste: 'Ancien poste',
        statut: StatutCandidature.entretien,
        dateCreation: date,
        dateRelance: DateTime(2026, 11, 10),
        notes: 'À conserver',
      ).toDatabase()..remove('date_modification');
      await ancienne.insert('candidatures', valeurs);
      await ancienne.close();
      final migree = (await repository.toutes()).single;
      expect(migree.id, 7);
      expect(migree.entreprise, 'Ancienne entreprise');
      expect(migree.dateModification, date);
      expect(migree.dateCreation, date);
      expect(migree.dateRelance, DateTime(2026, 11, 10));
      expect(migree.notes, 'À conserver');
      await repository.fermer();
      repository = SqliteCandidatureRepository(chemin: chemin);
      expect((await repository.toutes()).single.dateModification, date);
      final nouvelle = await repository.enregistrer(
        Candidature(
          entreprise: 'Après migration',
          poste: 'Mobile',
          statut: StatutCandidature.offre,
          dateCreation: DateTime(2026, 11, 5),
        ),
      );
      expect(nouvelle.id, greaterThan(7));
      expect((await repository.toutes()).length, 2);
    },
  );

  testWidgets('Une écriture ou suppression sans ligne correspondante échoue', (
    tester,
  ) async {
    final inexistante = Candidature(
      id: 999,
      entreprise: 'Absente',
      poste: 'Mobile',
      statut: StatutCandidature.envoyee,
      dateCreation: DateTime(2026, 11, 5),
    );
    await expectLater(repository.enregistrer(inexistante), throwsStateError);
    await expectLater(repository.supprimer(999), throwsStateError);
    expect(await repository.toutes(), isEmpty);
  });
}
