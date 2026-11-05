import '../models/candidature.dart';

// shortcut: repository factice sans stockage durable, à remplacer au TP persistance.
class CandidatureRepository {
  Future<void> enregistrer(Candidature candidature) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }

  Future<void> supprimer(int id) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }
}
