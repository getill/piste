import 'package:tp_intro/data/candidature_repository.dart';
import 'package:tp_intro/models/candidature.dart';

List<Candidature> candidaturesDemo() => [
  Candidature(
    id: 1,
    poste: 'Développeur Flutter junior',
    entreprise: 'Atelier Mobile',
    statut: StatutCandidature.envoyee,
    dateCreation: DateTime(2026, 11, 4),
  ),
  Candidature(
    id: 2,
    poste: 'Développeuse web en alternance',
    entreprise: 'Studio Numérique',
    statut: StatutCandidature.entretien,
    dateCreation: DateTime(2026, 11, 5),
  ),
];

class FakeCandidatureRepository implements CandidatureRepository {
  FakeCandidatureRepository([Iterable<Candidature> initiales = const []])
    : _donnees = {for (final item in initiales) item.id!: item};

  final Map<int, Candidature> _donnees;
  bool echecLecture = false;
  bool echecEcriture = false;
  bool echecSuppression = false;
  Future<void>? attenteLecture;
  Future<void>? attenteEcriture;
  int enregistrements = 0;

  @override
  Future<List<Candidature>> toutes() async {
    await attenteLecture;
    if (echecLecture) throw Exception('Échec de lecture simulé');
    return _donnees.values.toList()..sort((a, b) {
      final date = b.dateModification.compareTo(a.dateModification);
      return date == 0 ? b.id!.compareTo(a.id!) : date;
    });
  }

  @override
  Future<Candidature> enregistrer(Candidature candidature) async {
    enregistrements++;
    await attenteEcriture;
    if (echecEcriture) throw Exception('Échec d’écriture simulé');
    final id =
        candidature.id ??
        _donnees.keys.fold(0, (max, id) => id > max ? id : max) + 1;
    if (candidature.id != null && !_donnees.containsKey(id)) {
      throw StateError('Candidature introuvable.');
    }
    final enregistree = Candidature.fromDatabase({
      ...candidature.toDatabase(),
      'id': id,
    });
    _donnees[id] = enregistree;
    return enregistree;
  }

  @override
  Future<void> supprimer(int id) async {
    if (echecSuppression) throw Exception('Échec de suppression simulé');
    if (_donnees.remove(id) == null) {
      throw StateError('Candidature introuvable.');
    }
  }

  @override
  Future<void> fermer() async {}
}
