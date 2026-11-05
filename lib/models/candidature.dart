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
    required this.id,
    required this.poste,
    required this.entreprise,
    required this.statut,
    required this.dateCreation,
    this.dateRelance,
    this.lienOffre,
    this.notes,
    DateTime? dateModification,
  }) : dateModification = dateModification ?? dateCreation;

  final int id;
  final String poste;
  final String entreprise;
  final StatutCandidature statut;
  final DateTime dateCreation;
  final DateTime? dateRelance;
  final DateTime dateModification;
  final String? lienOffre;
  final String? notes;

  static bool lienOffreValide(String? valeur) {
    if (valeur == null || valeur.trim().isEmpty) return true;
    final uri = Uri.tryParse(valeur.trim());
    return uri != null &&
        (uri.scheme == 'https' || uri.scheme == 'http') &&
        uri.host.isNotEmpty;
  }
}
