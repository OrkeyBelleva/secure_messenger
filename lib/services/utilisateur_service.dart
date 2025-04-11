import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/utilisateur.dart';

class Role {
  static const String admin = 'administrateur';
  static const String moderateur = 'moderateur';
  static const String utilisateur = 'utilisateur';

  static List<String> tousLesRoles = [admin, moderateur, utilisateur];

  static Map<String, List<String>> permissions = {
    admin: [
      'gerer_utilisateurs',
      'valider_transactions',
      'gerer_groupes',
      'supprimer_messages',
      'voir_statistiques',
    ],
    moderateur: [
      'valider_transactions',
      'gerer_groupes',
      'supprimer_messages',
    ],
    utilisateur: [
      'envoyer_messages',
      'joindre_groupes',
      'telecharger_documents',
    ],
  };
}

class UtilisateurService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Créer un nouvel utilisateur
  Future<void> creerUtilisateur(Utilisateur utilisateur) async {
    try {
      await _db.collection('utilisateurs').doc(utilisateur.id).set({
        ...utilisateur.toJson(),
        'dateCreation': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Erreur lors de la création de l\'utilisateur: $e');
      rethrow;
    }
  }

  // Obtenir un utilisateur par ID
  Future<Utilisateur?> getUtilisateur(String id) async {
    try {
      final doc = await _db.collection('utilisateurs').doc(id).get();
      if (!doc.exists) return null;
      return Utilisateur.fromJson(doc.data()!);
    } catch (e) {
      print('Erreur lors de la récupération de l\'utilisateur: $e');
      rethrow;
    }
  }

  // Mettre à jour le rôle d'un utilisateur
  Future<void> mettreAJourRole(String userId, String nouveauRole) async {
    try {
      if (!Role.tousLesRoles.contains(nouveauRole)) {
        throw Exception('Rôle invalide');
      }
      await _db.collection('utilisateurs').doc(userId).update({
        'role': nouveauRole,
      });
    } catch (e) {
      print('Erreur lors de la mise à jour du rôle: $e');
      rethrow;
    }
  }

  // Obtenir tous les utilisateurs
  Stream<List<Utilisateur>> getTousLesUtilisateurs() {
    return _db.collection('utilisateurs').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Utilisateur.fromJson(doc.data()))
          .toList();
    });
  }

  // Vérifier si un utilisateur a une permission spécifique
  bool utilisateurAPermission(Utilisateur utilisateur, String permission) {
    final permissions = Role.permissions[utilisateur.role] ?? [];
    return permissions.contains(permission);
  }

  // Désactiver un compte utilisateur
  Future<void> desactiverCompte(String userId) async {
    try {
      await _db.collection('utilisateurs').doc(userId).update({
        'estActif': false,
      });
    } catch (e) {
      print('Erreur lors de la désactivation du compte: $e');
      rethrow;
    }
  }

  // Réactiver un compte utilisateur
  Future<void> reactiverCompte(String userId) async {
    try {
      await _db.collection('utilisateurs').doc(userId).update({
        'estActif': true,
      });
    } catch (e) {
      print('Erreur lors de la réactivation du compte: $e');
      rethrow;
    }
  }

  // Mettre à jour le profil utilisateur
  Future<void> mettreAJourProfil(
    String userId, {
    String? nom,
    String? email,
    String? photoUrl,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (nom != null) updates['nom'] = nom;
      if (email != null) updates['email'] = email;
      if (photoUrl != null) updates['photoUrl'] = photoUrl;

      await _db.collection('utilisateurs').doc(userId).update(updates);
    } catch (e) {
      print('Erreur lors de la mise à jour du profil: $e');
      rethrow;
    }
  }

  // Rechercher des utilisateurs
  Future<List<Utilisateur>> rechercherUtilisateurs(String query) async {
    try {
      final resultat = await _db
          .collection('utilisateurs')
          .where('nom', isGreaterThanOrEqualTo: query)
          .where('nom', isLessThan: '${query}z')
          .get();

      return resultat.docs
          .map((doc) => Utilisateur.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Erreur lors de la recherche d\'utilisateurs: $e');
      rethrow;
    }
  }

  // Obtenir les statistiques d'un utilisateur
  Future<Map<String, dynamic>> getStatistiquesUtilisateur(String userId) async {
    try {
      final messages = await _db
          .collection('messages')
          .where('expediteurId', isEqualTo: userId)
          .get();

      final documents = await _db
          .collection('documents')
          .where('proprietaireId', isEqualTo: userId)
          .get();

      final groupes = await _db
          .collection('groupes')
          .where('membres', arrayContains: userId)
          .get();

      return {
        'nombreMessages': messages.size,
        'nombreDocuments': documents.size,
        'nombreGroupes': groupes.size,
      };
    } catch (e) {
      print('Erreur lors de la récupération des statistiques: $e');
      rethrow;
    }
  }
}
