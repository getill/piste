enum StatutCandidature {
  envoyee('Envoyée'),
  entretien('Entretien'),
  acceptee('Acceptée'),
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
    required this.dateCandidature,
    this.dateRelance,
  });

  final int id;
  final String poste;
  final String entreprise;
  final StatutCandidature statut;
  final DateTime dateCandidature;
  final DateTime? dateRelance;
}
