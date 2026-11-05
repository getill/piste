# Livraison Android de Piste

## Version

- Version : `1.0.0`, numéro de build `1`.
- Compatibilité : Android 7.0 (API 24) ou plus récent.
- APK universelle : ARM 32 bits, ARM 64 bits et x86_64, environ 53 Mo.
- Application de diffusion : `io.github.getill.piste`, nom affiché **Piste**.
- Application de développement : `io.github.getill.piste.debug`.
- L’ancienne application des TP, `com.example.tp_intro`, conserve son installation
  et ses données. Les nouvelles applications ont chacune leur propre base SQLite.

## Vérification de l’artefact

L’APK locale prête pour diffusion est `build/livraison/piste-1.0.0-android.apk`.
Sa somme de contrôle est dans `build/livraison/SHA256SUMS.txt`.

SHA-256 de l’APK :

```text
fc6ede44a22a30a2cb9621e3f76a91515c74b5946755a95ba28105c77746e793
```

Le contrôle `apksigner verify --verbose --print-certs` confirme une signature APK
v2 valide avec une clé RSA 3072 bits et le certificat `CN=Piste, OU=Atelier, O=getill`.
Son empreinte SHA-256 publique est :

```text
8cf794cd9973e467ec1513ea7f95f538cfcf9b232e9a9660c98bb1bc7afc1c97
```

L’APK n’est pas débogable et contient la licence Inter. Ces empreintes sont
publiques ; elles ne contiennent pas la clé privée ni son mot de passe.

## Installer l’APK

Après publication, ouvrir la [release v1.0.0](https://github.com/getill/piste/releases/tag/v1.0.0)
et télécharger `piste-1.0.0-android.apk` depuis un appareil Android.
Autoriser, si Android le demande, l’installation depuis l’application ayant ouvert
le fichier, puis installer **Piste**. Une installation neuve ouvre un accueil vide. Android 7.0 ou plus récent est nécessaire.

Le fichier `SHA256SUMS.txt` joint à la release permet de vérifier le téléchargement :

```bash
sha256sum -c SHA256SUMS.txt
```

Avec un appareil relié par USB et le débogage USB activé :

```bash
adb install -r piste-1.0.0-android.apk
```

## Scénario de démonstration

1. Dans Piste, appuyer sur **+**. Soumettre le formulaire vide : les deux champs
   obligatoires affichent une erreur et le formulaire reste ouvert.
2. Renseigner une entreprise et un poste, choisir un statut et une relance,
   puis enregistrer. Consulter la fiche et ses dates.
3. Fermer complètement l’application puis la relancer. Ouvrir la candidature et
   vérifier qu’elle est toujours présente.
4. Modifier le statut ou la relance, enregistrer, fermer et relancer encore.
5. Dans **Candidatures**, essayer une recherche et un filtre qui masque l’entrée.
   Dans **Bilan**, vérifier que la candidature est toujours comptée.
6. Sur la fiche, demander la suppression puis l’annuler : l’entrée reste présente.
   La supprimer après confirmation, fermer et relancer Piste : l’entrée a disparu.

Validation effectuée le 5 novembre 2026 : analyse sans erreur, 24 tests unitaires
et widgets réussis, APK release installée sur Android 16. Le scénario ci-dessus
a été exécuté, avec trois arrêts complets et relances : création, relance modifiée
du 12 au 19 novembre, suppression annulée puis confirmée. L’entrée a disparu
après le dernier redémarrage. Le nom et l’icône ont été vérifiés dans Android.

Les anciennes captures de débogage sont conservées comme historique des TP.
[Captures de la version de livraison et détail de la recette](captures/livraison/README.md).
Le test sur un téléphone physique reste à réaliser si un appareil est disponible.

## Compiler depuis les sources

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

L’APK produit se trouve dans `build/app/outputs/flutter-apk/app-release.apk`.
La compilation release nécessite une clé de diffusion privée et
`android/key.properties`. Un clone du dépôt peut lancer les tests et compiler
la variante debug sans posséder cette clé. Une compilation release sans les
propriétés de signature est refusée explicitement.

Pour préparer une autre installation de compilation avec une clé existante,
restaurer la clé et les propriétés privées. Le chemin `storeFile` est relatif au
dossier `android/`. Le modèle sans secret est `android/key.properties.example`.

Pour un nouveau projet qui n’a jamais été publié, la clé peut être générée avec :

```bash
mkdir -p .signing
keytool -genkeypair -keystore .signing/piste-release.jks -storetype JKS \
  -alias piste -keyalg RSA -keysize 3072 -validity 10000
cp android/key.properties.example android/key.properties
```

Renseigner ensuite les mots de passe choisis dans le fichier privé.
**Pour Piste déjà signée, conserver et réutiliser la clé existante : ne pas en
recréer une pour les mises à jour.**

## Sauvegarde de la signature

La clé de cette livraison est dans `.signing/piste-release.jks`. Les mots de passe
sont dans `android/key.properties`. Ces deux fichiers sont exclus de Git et ne
font pas partie de l’APK ou des pièces jointes de la release.

**Sauvegarder ces deux fichiers ensemble, dans un emplacement privé et sécurisé
hors de ce dépôt.** La même clé sera nécessaire pour installer les futures mises
à jour sur les installations existantes.

## Références

- [Publication Android avec Flutter](https://docs.flutter.dev/deployment/android)
- [Signature Android](https://developer.android.com/studio/publish/app-signing)
