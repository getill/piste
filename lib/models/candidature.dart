enum StatutCandidature {
  envoyee('Envoyée'),
  enCours('En cours'),
  entretien('Entretien'),
  offre('Offre'),
  refusee('Refusée');

  const StatutCandidature(this.libelle);
  final String libelle;
}

class Candidature {
  const Candidature({
    this.id,
    required this.poste,
    required this.entreprise,
    required this.statut,
    required this.dateCreation,
    this.dateRelance,
    this.lienOffre,
    this.notes,
    DateTime? dateModification,
  }) : dateModification = dateModification ?? dateCreation;

  final int? id;
  final String poste;
  final String entreprise;
  final StatutCandidature statut;
  final DateTime dateCreation;
  final DateTime? dateRelance;
  final DateTime dateModification;
  final String? lienOffre;
  final String? notes;

  Map<String, Object?> toDatabase() => {
    'id': id,
    'poste': poste,
    'entreprise': entreprise,
    'status': statut.name,
    'notes': notes ?? '',
    'url': lienOffre ?? '',
    'date_creation': dateCreation.toIso8601String(),
    'date_modification': dateModification.toIso8601String(),
    'prochaine_relance': dateRelance?.toIso8601String(),
  };

  factory Candidature.fromDatabase(Map<String, Object?> ligne) {
    final notes = ligne['notes'] as String;
    final url = ligne['url'] as String;
    return Candidature(
      id: ligne['id'] as int,
      poste: ligne['poste'] as String,
      entreprise: ligne['entreprise'] as String,
      statut: StatutCandidature.values.byName(ligne['status'] as String),
      dateCreation: DateTime.parse(ligne['date_creation'] as String),
      dateModification: DateTime.parse(ligne['date_modification'] as String),
      dateRelance: ligne['prochaine_relance'] == null
          ? null
          : DateTime.parse(ligne['prochaine_relance'] as String),
      notes: notes.isEmpty ? null : notes,
      lienOffre: url.isEmpty ? null : url,
    );
  }

  static bool lienOffreValide(String? valeur) {
    if (valeur == null || valeur.trim().isEmpty) return true;
    final uri = Uri.tryParse(valeur.trim());
    return uri != null &&
        (uri.scheme == 'https' || uri.scheme == 'http') &&
        uri.host.isNotEmpty;
  }
}
