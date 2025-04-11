import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/groupe.dart';
import '../models/membre.dart';

class GroupeHierarchieService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Créer un nouveau groupe
  Future<String> creerGroupe({
    required String nom,
    required String description,
    required String createurId,
    required List<String> roles,
    String? groupeParentId,
  }) async {
    final groupe = Groupe(
      id: '',
      nom: nom,
      description: description,
      createurId: createurId,
      dateCreation: DateTime.now(),
      roles: roles,
      groupeParentId: groupeParentId,
      estArchive: false,
    );

    final docRef = await _db.collection('groupes').add(groupe.toMap());

    // Ajouter le créateur comme administrateur
    await ajouterMembre(
      groupeId: docRef.id,
      utilisateurId: createurId,
      role: 'administrateur',
    );

    return docRef.id;
  }

  // Mettre à jour un groupe
  Future<void> mettreAJourGroupe({
    required String groupeId,
    String? nom,
    String? description,
    List<String>? roles,
    bool? estArchive,
  }) async {
    final updates = <String, dynamic>{
      if (nom != null) 'nom': nom,
      if (description != null) 'description': description,
      if (roles != null) 'roles': roles,
      if (estArchive != null) 'estArchive': estArchive,
      'dateMiseAJour': FieldValue.serverTimestamp(),
    };

    await _db.collection('groupes').doc(groupeId).update(updates);
  }

  // Ajouter un membre au groupe
  Future<void> ajouterMembre({
    required String groupeId,
    required String utilisateurId,
    required String role,
  }) async {
    final membre = Membre(
      groupeId: groupeId,
      utilisateurId: utilisateurId,
      role: role,
      dateAjout: DateTime.now(),
      estActif: true,
    );

    await _db.collection('membres').add(membre.toMap());
  }

  // Mettre à jour le rôle d'un membre
  Future<void> mettreAJourRoleMembre({
    required String groupeId,
    required String utilisateurId,
    required String nouveauRole,
  }) async {
    final querySnapshot = await _db
        .collection('membres')
        .where('groupeId', isEqualTo: groupeId)
        .where('utilisateurId', isEqualTo: utilisateurId)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      await querySnapshot.docs.first.reference.update({
        'role': nouveauRole,
        'dateMiseAJour': FieldValue.serverTimestamp(),
      });
    }
  }

  // Retirer un membre du groupe
  Future<void> retirerMembre({
    required String groupeId,
    required String utilisateurId,
  }) async {
    final querySnapshot = await _db
        .collection('membres')
        .where('groupeId', isEqualTo: groupeId)
        .where('utilisateurId', isEqualTo: utilisateurId)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      await querySnapshot.docs.first.reference.update({
        'estActif': false,
        'dateRetrait': FieldValue.serverTimestamp(),
      });
    }
  }

  // Obtenir les groupes d'un utilisateur
  Stream<List<Groupe>> obtenirGroupesUtilisateur(String utilisateurId) {
    return _db
        .collection('membres')
        .where('utilisateurId', isEqualTo: utilisateurId)
        .where('estActif', isEqualTo: true)
        .snapshots()
        .asyncMap((membresSnapshot) async {
      final groupeIds = membresSnapshot.docs
          .map((doc) => doc.data()['groupeId'] as String)
          .toList();

      if (groupeIds.isEmpty) return [];

      final groupesSnapshot = await _db
          .collection('groupes')
          .where(FieldPath.documentId, whereIn: groupeIds)
          .where('estArchive', isEqualTo: false)
          .get();

      return groupesSnapshot.docs
          .map((doc) => Groupe.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Obtenir les membres d'un groupe
  Stream<List<Membre>> obtenirMembresGroupe(String groupeId) {
    return _db
        .collection('membres')
        .where('groupeId', isEqualTo: groupeId)
        .where('estActif', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Membre.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Obtenir les sous-groupes
  Future<List<Groupe>> obtenirSousGroupes(String groupeParentId) async {
    final snapshot = await _db
        .collection('groupes')
        .where('groupeParentId', isEqualTo: groupeParentId)
        .where('estArchive', isEqualTo: false)
        .get();

    return snapshot.docs
        .map((doc) => Groupe.fromMap(doc.data(), doc.id))
        .toList();
  }

  // Vérifier si un utilisateur est membre d'un groupe
  Future<bool> estMembreGroupe({
    required String groupeId,
    required String utilisateurId,
  }) async {
    final snapshot = await _db
        .collection('membres')
        .where('groupeId', isEqualTo: groupeId)
        .where('utilisateurId', isEqualTo: utilisateurId)
        .where('estActif', isEqualTo: true)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  // Obtenir le rôle d'un utilisateur dans un groupe
  Future<String?> obtenirRoleUtilisateur({
    required String groupeId,
    required String utilisateurId,
  }) async {
    final snapshot = await _db
        .collection('membres')
        .where('groupeId', isEqualTo: groupeId)
        .where('utilisateurId', isEqualTo: utilisateurId)
        .where('estActif', isEqualTo: true)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.data()['role'] as String?;
    }
    return null;
  }

  // Vérifier les permissions d'un utilisateur
  Future<bool> verifierPermission({
    required String groupeId,
    required String utilisateurId,
    required String permission,
  }) async {
    final role = await obtenirRoleUtilisateur(
      groupeId: groupeId,
      utilisateurId: utilisateurId,
    );

    if (role == null) return false;

    final rolesPermissions = {
      'administrateur': [
        'gerer_membres',
        'gerer_roles',
        'gerer_messages',
        'gerer_documents',
        'gerer_sous_groupes',
      ],
      'moderateur': [
        'gerer_messages',
        'gerer_documents',
      ],
      'membre': [
        'envoyer_messages',
        'voir_documents',
      ],
    };

    return rolesPermissions[role]?.contains(permission) ?? false;
  }

  // Archiver un groupe
  Future<void> archiverGroupe(String groupeId) async {
    await _db.collection('groupes').doc(groupeId).update({
      'estArchive': true,
      'dateArchivage': FieldValue.serverTimestamp(),
    });
  }

  // Restaurer un groupe archivé
  Future<void> restaurerGroupe(String groupeId) async {
    await _db.collection('groupes').doc(groupeId).update({
      'estArchive': false,
      'dateArchivage': null,
    });
  }

  // Obtenir la hiérarchie complète d'un groupe
  Future<List<Groupe>> obtenirHierarchie(String groupeId) async {
    final List<Groupe> hierarchie = [];
    String? currentGroupeId = groupeId;

    while (currentGroupeId != null) {
      final snapshot =
          await _db.collection('groupes').doc(currentGroupeId).get();

      if (!snapshot.exists) break;

      final groupe = Groupe.fromMap(snapshot.data()!, snapshot.id);
      hierarchie.insert(0, groupe);
      currentGroupeId = groupe.groupeParentId;
    }

    return hierarchie;
  }
}
