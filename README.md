# Secure Messenger - Application de Messagerie Sécurisée

Application de messagerie sécurisée pour réseau local avec gestion de documents et validation de transactions.

## Fonctionnalités

- **Messagerie Instantanée**
  - Messages en temps réel
  - Support des pièces jointes (images, documents)
  - Statut des messages (envoyé, lu)

- **Gestion des Documents**
  - Téléchargement et validation
  - Historique des modifications
  - Système de validation

- **Gestion des Groupes**
  - Hiérarchie de groupes
  - Rôles et permissions
  - Sous-groupes

- **Validation des Transactions**
  - Workflow de validation
  - Historique des transactions
  - Statistiques

## Installation

1. **Prérequis**
   ```bash
   # Installer Flutter
   https://flutter.dev/docs/get-started/install

   # Installer les dépendances
   flutter pub get
   ```

2. **Configuration Firebase Local**
   - Créer un projet Firebase local
   - Copier le fichier de configuration dans le dossier `android/app`
   - Modifier l'adresse IP dans `lib/services/reseau_local_service.dart`

3. **Lancer l'application**
   ```bash
   flutter run
   ```

## Structure du Projet

```
lib/
├── models/          # Modèles de données
├── screens/         # Écrans de l'application
├── services/        # Services (Firebase, Local)
└── widgets/         # Widgets réutilisables
```

## Guide d'Utilisation

1. **Connexion**
   - Utiliser votre email professionnel
   - Mot de passe sécurisé requis

2. **Messages**
   - Créer/rejoindre des groupes
   - Envoyer des messages/pièces jointes
   - Gérer les conversations

3. **Documents**
   - Télécharger des documents
   - Soumettre pour validation
   - Suivre l'état des validations

4. **Transactions**
   - Créer des transactions
   - Ajouter des documents
   - Suivre le processus de validation

5. **Administration**
   - Gérer les utilisateurs
   - Configurer les groupes
   - Définir les rôles

## Sécurité

- Application en réseau local uniquement
- Authentification requise
- Gestion des rôles et permissions
- Validation des documents

## Maintenance

1. **Sauvegarde**
   - Sauvegarder régulièrement la base de données
   - Exporter les configurations importantes

2. **Mise à jour**
   - Vérifier les mises à jour Flutter
   - Mettre à jour les dépendances
   ```bash
   flutter pub upgrade
   ```

3. **Dépannage**
   - Vérifier la connexion réseau
   - Consulter les logs d'erreur
   - Redémarrer le service si nécessaire

## Dépendances Principales

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^2.x.x
  cloud_firestore: ^4.x.x
  firebase_storage: ^11.x.x
  firebase_messaging: ^14.x.x
  provider: ^6.x.x
  file_picker: ^5.x.x
  uuid: ^3.x.x
  path: ^1.x.x
```

## À Faire Seul

1. **Personnalisation**
   - Modifier les couleurs (lib/theme.dart)
   - Ajouter des icônes personnalisées
   - Adapter les textes

2. **Configuration**
   - Définir les rôles spécifiques
   - Configurer les workflows
   - Ajuster les limites (taille fichiers, etc.)

3. **Tests**
   - Tester en conditions réelles
   - Vérifier les performances
   - Valider les workflows

## Support

Pour toute question ou problème :
1. Consulter la documentation
2. Vérifier les logs
3. Contacter le support technique

## Licence

Application développée pour usage interne uniquement.
Tous droits réservés.
