# Captures fournies depuis VS Code

Les trois captures ont été fournies et vérifiées :

- [Arborescence de lib/](01-arborescence-lib.png) : les sept fichiers Dart sont visibles.
- [flutter doctor](02-flutter-doctor.png) : « No issues found! ».
- [flutter test](03-flutter-test.png) : 21 tests réussis, « All tests passed! ».

Les captures de l’application exécutée sur l’émulateur sont dans le dossier parent.
Pour refaire ces captures, ouvre le dossier `tp_intro` dans VS Code et suis ces étapes :

| Fichier | Manipulation | Ce qui doit être visible |
| --- | --- | --- |
| `01-arborescence-lib.png` | Dans l’explorateur de VS Code, déplie `lib/`, puis `data/`, `models/`, `state/` et `ui/`. | Tous les fichiers Dart de `lib/`, avec des noms lisibles. |
| `02-flutter-doctor.png` | Démarre l’émulateur. Dans le terminal intégré, lance `flutter doctor` et attends la fin. | La commande et son résultat, notamment Flutter, Android toolchain et Connected device. |
| `03-flutter-test.png` | Depuis la racine du projet, lance `flutter test` dans le terminal intégré et attends la fin. | La commande et le résultat final `All tests passed!`. |

Agrandis le terminal ou réduis légèrement son zoom si le résultat ne tient pas.
Si plusieurs captures sont nécessaires, ajoute un suffixe `-suite` au nom.
Conserve les avertissements visibles : s’il y a une erreur Android ou un test en
échec, garde le résultat et transmets-le pour correction avant de finaliser le rendu.

Ces fichiers doivent montrer les commandes réellement exécutées. Ne remplace pas
ces captures par du texte copié, un montage ou une maquette.
