# Guide d'Installation Rapide

1. Installer Flutter :
   - Télécharger Flutter SDK depuis : https://docs.flutter.dev/get-started/install/windows
   - Extraire le fichier zip dans un dossier (par exemple : C:\src\flutter)
   - Ajouter flutter\bin au PATH système

2. Installer Android Studio :
   - Télécharger depuis : https://developer.android.com/studio
   - Installer Android Studio
   - Lancer Android Studio et installer les plugins Flutter et Dart

3. Configurer Firebase :
   - Créer un projet sur Firebase Console
   - Télécharger le fichier google-services.json
   - Placer le fichier dans android/app/

4. Installer les dépendances :
   ```
   flutter pub get
   ```

5. Lancer l'application :
   ```
   flutter run
   ```

## Vérification de l'installation

Pour vérifier que tout est bien installé, ouvrez un terminal et exécutez :
```
flutter doctor
```

Cela vérifiera si toutes les dépendances sont correctement installées.
