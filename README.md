# Piste — TP Flutter

Application de suivi de candidatures réalisée au fil des TP.

## État du projet

- TP 1 : accueil, deux candidatures de démonstration, liste défilante et onglet Bilan.
- TP 2 : création, consultation, modification et suppression avec confirmation,
  validation des champs, choix de relance et gestion d’un échec d’enregistrement.

Les données restent en mémoire et sont réinitialisées au redémarrage. SQLite et
le calcul du bilan seront ajoutés dans les TP suivants.

## Lancer et vérifier

Avec Flutter installé et un appareil ou un émulateur disponible :

```bash
flutter doctor
flutter pub get
flutter run
```

```bash
flutter analyze
flutter test
```

## Organisation

`main.dart` possède et détruit un unique `CandidatureController`, injecté dans les
écrans. `lib/models/` décrit les candidatures, `lib/state/` gère la liste partagée,
`lib/data/` contient le repository factice asynchrone et `lib/ui/` les trois écrans.
Les `TextEditingController` appartiennent uniquement au formulaire et sont détruits
avec lui. Une modification annulée ne touche pas aux données de la liste.

Le cours PDF « Cours flutter 2026 » sert de référence métier : poste et entreprise
obligatoires, lien d’offre, notes et relance facultatifs. La date de création est
fixée au premier enregistrement ; la date de modification est actualisée à chaque
sauvegarde. Les cinq statuts suivent le kit Piste Figma 2026 : Envoyée, En cours,
Entretien, Offre et Refusée. Le ZIP de code source mentionné dans le PDF n’était
pas présent dans les fichiers fournis.

## Vérifications du TP 2

Les tests couvrent le parcours création → fiche → modification → suppression,
la suppression annulée, les champs vides ou composés d’espaces, les liens invalides,
le double enregistrement, les erreurs et l’utilisation sur un écran de 320 × 480.

Pour reproduire un échec sans SQLite, les tests injectent `RepositoryAvecErreur`
ou `RepositoryEnEchec` à la place du repository factice. L’exception remonte au
`try/catch` du formulaire : il reste ouvert, conserve les champs et affiche un
message. Le `finally` réactive Enregistrer pour permettre une nouvelle tentative.
Fermer l’écran ferait perdre le brouillon et présenterait une opération échouée
comme une réussite. La liste n’est modifiée et notifiée qu’après succès.

## Captures réelles

Captures produites avec `adb screencap` sur l’émulateur Android exécutant le code :

- [Liste avec données](docs/captures/tp2-liste.png)
- [Fiche détail](docs/captures/tp2-detail.png)
- [Formulaire invalide](docs/captures/tp2-formulaire-invalide.png)

Les captures VS Code (arborescence `lib/`, terminaux `flutter doctor` et
`flutter test`) restent à réaliser depuis l’éditeur. Les maquettes du kit Figma
ne sont pas utilisées comme preuves de fonctionnement.
