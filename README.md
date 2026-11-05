# Piste — TP Flutter

Application de suivi de candidatures réalisée au fil des TP.

Le TP 1 affiche deux candidatures de démonstration dans une liste défilante,
un bouton Ajouter et un onglet Bilan. Le formulaire et le calcul du bilan
seront développés dans les prochains TP.

## Lancer le projet

Avec le SDK Flutter installé et un appareil ou un émulateur disponible :

```bash
flutter doctor
flutter pub get
flutter run
```

## Vérifier le projet

```bash
flutter analyze
flutter test
```

Le code de l’accueil se trouve dans `lib/ui/accueil_page.dart` et le point
d’entrée dans `lib/main.dart`. Les tests vérifient l’affichage, les commandes
et le comportement sur un écran de 320 × 480.
