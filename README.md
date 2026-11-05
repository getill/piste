# Piste — TP Flutter

Application de suivi de candidatures réalisée au fil des TP.

## État du projet

- TP 1 : accueil, deux candidatures de démonstration, liste défilante et onglet Bilan.
- TP 2 : création, consultation, modification et suppression avec confirmation,
  validation des champs, choix de relance et gestion d’un échec d’enregistrement.
- TP 3 : SQLite en version 2, migration depuis la version 1, chargement et erreur
  avec Réessayer, recherche sur entreprise/poste, filtres par statut et bilan global.

Les données sont conservées dans `piste.db` entre les lancements sur Android et iOS.
Une première installation ouvre une liste vide. Les anciennes données temporaires
saisies au TP 2 ne peuvent pas être récupérées après leur disparition de la mémoire.
Les exemples de candidatures sont désormais réservés aux tests.
La version actuelle utilise `sqflite` pour Android/iOS ; le stockage Web et Linux
n’est pas configuré.

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
`lib/data/` contient le contrat du repository et son implémentation SQLite ;
`lib/ui/` contient les trois écrans. Les tests injectent `test/fake_repository.dart`.
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

Pour reproduire un échec sans SQLite, les tests injectent `FakeCandidatureRepository`
avec `echecEcriture = true` ou `echecSuppression = true`. L’exception remonte au
`try/catch` du formulaire : il reste ouvert, conserve les champs et affiche un
message. Le `finally` réactive Enregistrer pour permettre une nouvelle tentative.
Fermer l’écran ferait perdre le brouillon et présenterait une opération échouée
comme une réussite. La liste n’est modifiée et notifiée qu’après succès.

## Vérifications du TP 3

Les tests unitaires et widgets utilisent `test/fake_repository.dart`, sans plugin
natif. `echecLecture = true` doit afficher une erreur et Réessayer. Une exception de
lecture ne signifie pas que la base est vide : afficher « Aucune candidature »
masquerait l’échec et pourrait inciter à recréer des données déjà enregistrées.
Après une écriture réussie suivie d’une lecture échouée, l’écran signale le problème
de rechargement sans faire répéter l’écriture.

Le bilan compte toujours `controller.candidatures`, tandis que la liste utilise
`controller.visibles`. La recherche et le statut se combinent et ne modifient pas
les totaux. Un bilan vide utilise des progressions à zéro.

Validation du 5 novembre 2026 : `flutter analyze` sans erreur, 21 tests unitaires
et widgets réussis, et 3 tests SQLite réussis sur l’émulateur Android 16.

Les tests SQLite natifs s’exécutent sur un émulateur ou un appareil :

```bash
flutter test integration_test/candidature_repository_test.dart -d emulator-5554
```

Ils utilisent exclusivement `piste_recette_test.db`, supprimée en fin de test :
création d’une base v2, création/édition/suppression après réouvertures, conservation
des dates et des champs facultatifs, refus d’écrire sur un identifiant absent,
requêtes paramétrées et migration d’une base v1. La migration ajoute
`date_modification` et la remplit avec `date_creation`, sans effacer les lignes.

Recette sur l’application réellement lancée : créer une candidature, arrêter
complètement Piste puis la rouvrir ; modifier sa relance, répéter l’arrêt et
contrôler la date ; supprimer après confirmation, arrêter encore puis vérifier
l’absence de la candidature. Un hot reload ne valide pas la persistance.
Ce parcours a été exécuté avec `am force-stop` puis relance de l’activité :
la candidature « Recette TP3 » a conservé sa relance au 12 novembre 2026,
puis sa suppression a été confirmée après un troisième arrêt complet.
La date de création est restée identique et la date de modification a changé.

## Captures réelles

Captures produites avec `adb screencap` sur l’émulateur Android exécutant le code :

- [Liste avec données](docs/captures/tp2-liste.png)
- [Fiche détail](docs/captures/tp2-detail.png)
- [Formulaire invalide](docs/captures/tp2-formulaire-invalide.png)
- [TP 3 : premier accueil vide](docs/captures/tp3-accueil-vide.png)
- [TP 3 : liste après redémarrage](docs/captures/tp3-apres-redemarrage.png)
- [TP 3 : fiche avec relance persistée](docs/captures/tp3-detail-persistant.png)
- [TP 3 : filtre masquant la candidature](docs/captures/tp3-filtre-sans-resultat.png)
- [TP 3 : bilan global malgré ce filtre](docs/captures/tp3-bilan-filtre-actif.png)
- [TP 3 : suppression après redémarrage](docs/captures/tp3-suppression-apres-redemarrage.png)

Les captures VS Code (arborescence `lib/`, terminaux `flutter doctor` et
`flutter test`) restent à réaliser depuis l’éditeur. Les maquettes du kit Figma
ne sont pas utilisées comme preuves de fonctionnement.
