import 'package:flutter/foundation.dart';

import '../data/candidature_repository.dart';
import '../models/candidature.dart';

enum EtatChargement { loading, empty, success, error }

class CandidatureController extends ChangeNotifier {
  CandidatureController(this._repository);

  final CandidatureRepository _repository;
  List<Candidature> _candidatures = [];
  EtatChargement etat = EtatChargement.loading;
  String? messageErreur;
  String _recherche = '';
  StatutCandidature? _filtre;
  bool _occupe = false;
  bool _detruit = false;

  List<Candidature> get candidatures => List.unmodifiable(_candidatures);
  StatutCandidature? get filtre => _filtre;
  bool get occupe => _occupe;

  List<Candidature> get visibles {
    final recherche = _recherche.trim().toLowerCase();
    return _candidatures.where((candidature) {
      final texte = '${candidature.entreprise} ${candidature.poste}'
          .toLowerCase();
      return (_filtre == null || candidature.statut == _filtre) &&
          texte.contains(recherche);
    }).toList();
  }

  void rechercher(String valeur) {
    _recherche = valeur;
    _notifier();
  }

  void filtrer(StatutCandidature? valeur) {
    _filtre = valeur;
    _notifier();
  }

  Candidature candidature(int id) =>
      _candidatures.firstWhere((candidature) => candidature.id == id);

  Future<void> _relire() async {
    _candidatures = await _repository.toutes();
    etat = _candidatures.isEmpty
        ? EtatChargement.empty
        : EtatChargement.success;
    messageErreur = null;
  }

  Future<void> charger() async {
    if (_occupe) return;
    _occupe = true;
    etat = EtatChargement.loading;
    messageErreur = null;
    _notifier();
    try {
      await _relire();
    } catch (_) {
      etat = EtatChargement.error;
      messageErreur = 'Chargement impossible. Réessayez.';
    } finally {
      _occupe = false;
      _notifier();
    }
  }

  Future<T> _modifier<T>(Future<T> Function() operation) async {
    if (_occupe) throw StateError('Une opération est déjà en cours.');
    _occupe = true;
    etat = EtatChargement.loading;
    messageErreur = null;
    _notifier();
    try {
      final resultat = await operation();
      if (_detruit) return resultat;
      try {
        await _relire();
      } catch (_) {
        // L’écriture a réussi : ne pas inciter à la répéter si la lecture échoue.
        etat = EtatChargement.error;
        messageErreur =
            'Modification enregistrée, mais rechargement impossible.';
      }
      return resultat;
    } catch (_) {
      etat = EtatChargement.error;
      messageErreur = 'Modification impossible. Réessayez.';
      rethrow;
    } finally {
      _occupe = false;
      _notifier();
    }
  }

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
      id: initiale?.id,
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
    return _modifier(() => _repository.enregistrer(nouvelle));
  }

  Future<void> supprimer(int id) => _modifier(() => _repository.supprimer(id));

  void _notifier() {
    if (!_detruit) notifyListeners();
  }

  @override
  void dispose() {
    _detruit = true;
    super.dispose();
  }
}
