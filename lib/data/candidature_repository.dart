import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import '../models/candidature.dart';

abstract class CandidatureRepository {
  Future<List<Candidature>> toutes();
  Future<Candidature> enregistrer(Candidature candidature);
  Future<void> supprimer(int id);
  Future<void> fermer();
}

class SqliteCandidatureRepository implements CandidatureRepository {
  SqliteCandidatureRepository({this.chemin});

  final String? chemin;
  Future<Database>? _ouverture;

  Future<Database> get _db async {
    try {
      return await (_ouverture ??= _ouvrir());
    } catch (_) {
      _ouverture = null;
      rethrow;
    }
  }

  Future<Database> _ouvrir() async {
    return openDatabase(
      chemin ?? path.join(await getDatabasesPath(), 'piste.db'),
      version: 2,
      onCreate: (db, version) => db.execute('''
        CREATE TABLE candidatures (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          entreprise TEXT NOT NULL,
          poste TEXT NOT NULL,
          status TEXT NOT NULL,
          notes TEXT NOT NULL,
          url TEXT NOT NULL,
          date_creation TEXT NOT NULL,
          date_modification TEXT NOT NULL,
          prochaine_relance TEXT
        )
      '''),
      onUpgrade: (db, ancienneVersion, nouvelleVersion) async {
        if (ancienneVersion < 2) {
          await db.execute(
            "ALTER TABLE candidatures ADD COLUMN date_modification TEXT NOT NULL DEFAULT ''",
          );
          await db.execute(
            'UPDATE candidatures SET date_modification = date_creation',
          );
        }
      },
    );
  }

  @override
  Future<List<Candidature>> toutes() async {
    final lignes = await (await _db).query(
      'candidatures',
      orderBy: 'date_modification DESC, id DESC',
    );
    return lignes.map(Candidature.fromDatabase).toList();
  }

  @override
  Future<Candidature> enregistrer(Candidature candidature) async {
    final db = await _db;
    final valeurs = candidature.toDatabase()..remove('id');
    final int id;
    if (candidature.id == null) {
      id = await db.insert('candidatures', valeurs);
    } else {
      id = candidature.id!;
      final lignes = await db.update(
        'candidatures',
        valeurs,
        where: 'id = ?',
        whereArgs: [id],
      );
      if (lignes != 1) throw StateError('Candidature introuvable.');
    }
    return Candidature.fromDatabase({...valeurs, 'id': id});
  }

  @override
  Future<void> supprimer(int id) async {
    final lignes = await (await _db).delete(
      'candidatures',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (lignes != 1) throw StateError('Candidature introuvable.');
  }

  @override
  Future<void> fermer() async {
    final ouverture = _ouverture;
    _ouverture = null;
    if (ouverture == null) return;
    final Database db;
    try {
      db = await ouverture;
    } catch (_) {
      return; // Une ouverture échouée ne laisse aucune connexion à fermer.
    }
    await db.close();
  }
}
