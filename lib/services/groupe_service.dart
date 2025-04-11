import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/groupe.dart';

class GroupeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Créer un nouveau groupe
  Future<String> creerGroupe(Groupe groupe) async {
    try {
      final docRef = await _db.collection('groupes').add(groupe.toJson());
      return docRef.id;
    } catch (e) {
      print('Erreur lors de la création du groupe: $e');
      rethrow;
    }
  }

  // Obtenir les groupes d'un utilisateur
  Stream<List<Groupe>> getGroupesUtilisateur(String userId) {
    return _db
        .collection('groupes')
        .where('membres', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Groupe.fromJson(doc.data())).toList();
    });
  }

  // Ajouter un membre au groupe
  Future<void> ajouterMembre(String groupeId, String userId) async {
    try {
      await _db.collection('groupes').doc(groupeId).update({
        'membres': FieldValue.arrayUnion([userId])
      });
    } catch (e) {
      print('Erreur lors de l\'ajout du membre: $e');
      rethrow;
    }
  }

  // Retirer un membre du groupe
  Future<void> retirerMembre(String groupeId, String userId) async {
    try {
      await _db.collection('groupes').doc(groupeId).update({
        'membres': FieldValue.arrayRemove([userId])
      });
    } catch (e) {
      print('Erreur lors du retrait du membre: $e');
      rethrow;
    }
  }

  // Supprimer un groupe
  Future<void> supprimerGroupe(String groupeId) async {
    try {
      await _db.collection('groupes').doc(groupeId).delete();
    } catch (e) {
      print('Erreur lors de la suppression du groupe: $e');
      rethrow;
    }
  }

  // Obtenir les groupes par type (achat ou vente)
  Stream<List<Groupe>> getGroupesParType(String type) {
    return _db
        .collection('groupes')
        .where('type', isEqualTo: type)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Groupe.fromJson(doc.data())).toList();
    });
  }
}
