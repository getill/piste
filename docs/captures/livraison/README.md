# Captures de l’APK release 1.0.0

Captures authentiques réalisées le 5 novembre 2026 sur l’émulateur Android 16,
après installation de `piste-1.0.0-android.apk`, signée avec la clé de diffusion.
Le mode release est non débogable et n’affiche pas la bannière DEBUG.

| Point vérifié | Capture |
| --- | --- |
| Nom et icône Android | [icone-nom.png](icone-nom.png) |
| Installation neuve sans données | [accueil-vide.png](accueil-vide.png) |
| Validation du formulaire | [formulaire-invalide.png](formulaire-invalide.png) |
| Accueil après création | [accueil.png](accueil.png) |
| Fiche après modification et relance | [detail.png](detail.png) |
| Compteurs du bilan | [bilan.png](bilan.png) |
| Suppression après arrêt complet et relance | [suppression-apres-redemarrage.png](suppression-apres-redemarrage.png) |

La candidature fictive Nexora / Flutter Developer a été créée par le formulaire,
conservée après un premier arrêt complet, puis sa relance a été changée du
12 au 19 novembre 2026. La modification a été retrouvée après un second arrêt.
La suppression a été annulée puis confirmée ; après un troisième arrêt et
relance, l’accueil est vide. Le processus a été arrêté avec `am force-stop`,
sans hot reload. Aucune exception Flutter ou Android fatale n’a été relevée
au dernier lancement.

La base de l’ancienne application de développement n’a pas été touchée.
La recette a utilisé l’application distincte `io.github.getill.piste`.
La validation sur un téléphone physique reste à faire si un appareil est disponible.
