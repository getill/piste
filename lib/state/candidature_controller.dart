import 'package:flutter/foundation.dart';

import '../data/candidature_repository.dart';
import '../models/candidature.dart';

class CandidatureController extends ChangeNotifier {
  CandidatureController({CandidatureRepository? repository})
    : _repository = repository ?? CandidatureRepository();

  final CandidatureRepository _repository;
  final List<Candidature> _candidatures = [
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
  int _prochainId = 3;

  List<Candidature> get candidatures => List.unmodifiable(_candidatures);

  Candidature candidature(int id) =>
      _candidatures.firstWhere((candidature) => candidature.id == id);

  Future<Candidature> enregistrer({
    Candidature? initiale,
    required String poste,
    required String entreprise,
    required StatutCandidature statut,
    DateTime? dateRelance,
    String? lienOffre,
    String? notes,
  }) async {
    if (poste.trim().isEmpty || entreprise.trim().isEmpty) {
      throw ArgumentError('Le poste et l’entreprise sont obligatoires.');
    }
    if (!Candidature.lienOffreValide(lienOffre)) {
      throw ArgumentError('Le lien doit être une adresse HTTP ou HTTPS.');
    }
    final maintenant = DateTime.now();
    final nouvelle = Candidature(
      id: initiale?.id ?? _prochainId++,
      poste: poste.trim(),
      entreprise: entreprise.trim(),
      statut: statut,
      dateCreation: initiale?.dateCreation ?? maintenant,
      dateModification: maintenant,
      lienOffre: lienOffre == null || lienOffre.trim().isEmpty
          ? null
          : lienOffre.trim(),
      notes: notes == null || notes.trim().isEmpty ? null : notes.trim(),
      dateRelance: dateRelance,
    );
    await _repository.enregistrer(nouvelle);
    if (initiale == null) {
      _candidatures.add(nouvelle);
    } else {
      final index = _candidatures.indexWhere((item) => item.id == initiale.id);
      if (index == -1) throw StateError('Candidature introuvable.');
      _candidatures[index] = nouvelle;
    }
    notifyListeners();
    return nouvelle;
  }

  Future<void> supprimer(int id) async {
    await _repository.supprimer(id);
    _candidatures.removeWhere((candidature) => candidature.id == id);
    notifyListeners();
  }
}
