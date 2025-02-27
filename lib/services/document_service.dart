import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class Document {
  final String id;
  final String nom;
  final String url;
  final String type;
  final DateTime date;
  final double? prix;
  final String? numeroDoc;
  final String proprietaireId;
  final bool estValide;

  Document({
    required this.id,
    required this.nom,
    required this.url,
    required this.type,
    required this.date,
    this.prix,
    this.numeroDoc,
    required this.proprietaireId,
    this.estValide = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'nom': nom,
    'url': url,
    'type': type,
    'date': date.toIso8601String(),
    'prix': prix,
    'numeroDoc': numeroDoc,
    'proprietaireId': proprietaireId,
    'estValide': estValide,
  };

  factory Document.fromJson(Map<String, dynamic> json) => Document(
    id: json['id'],
    nom: json['nom'],
    url: json['url'],
    type: json['type'],
    date: DateTime.parse(json['date']),
    prix: json['prix'],
    numeroDoc: json['numeroDoc'],
    proprietaireId: json['proprietaireId'],
    estValide: json['estValide'],
  );
}

class DocumentService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  // Télécharger un fichier
  Future<Document> telechargerDocument({
    required File fichier,
    required String nom,
    required String type,
    required String proprietaireId,
    double? prix,
    String? numeroDoc,
  }) async {
    try {
      final String id = _uuid.v4();
      final String extension = fichier.path.split('.').last;
      final String chemin = 'documents/$id.$extension';

      // Télécharger le fichier
      final ref = _storage.ref().child(chemin);
      await ref.putFile(fichier);
      final url = await ref.getDownloadURL();

      // Créer le document
      final document = Document(
        id: id,
        nom: nom,
        url: url,
        type: type,
        date: DateTime.now(),
        prix: prix,
        numeroDoc: numeroDoc,
        proprietaireId: proprietaireId,
      );

      // Sauvegarder les métadonnées
      await _db.collection('documents').doc(id).set(document.toJson());

      return document;
    } catch (e) {
      print('Erreur lors du téléchargement du document: $e');
      throw e;
    }
  }

  // Obtenir les documents d'un utilisateur
  Stream<List<Document>> getDocumentsUtilisateur(String userId) {
    return _db
        .collection('documents')
        .where('proprietaireId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Document.fromJson(doc.data()))
              .toList();
        });
  }

  // Valider un document
  Future<void> validerDocument(String documentId) async {
    try {
      await _db.collection('documents').doc(documentId).update({
        'estValide': true,
      });
    } catch (e) {
      print('Erreur lors de la validation du document: $e');
      throw e;
    }
  }

  // Supprimer un document
  Future<void> supprimerDocument(String documentId) async {
    try {
      // Supprimer le fichier du storage
      final doc = await _db.collection('documents').doc(documentId).get();
      final url = doc.data()?['url'] as String;
      final ref = _storage.refFromURL(url);
      await ref.delete();

      // Supprimer les métadonnées
      await _db.collection('documents').doc(documentId).delete();
    } catch (e) {
      print('Erreur lors de la suppression du document: $e');
      throw e;
    }
  }

  // Mettre à jour les métadonnées d'un document
  Future<void> mettreAJourDocument(String documentId, {
    double? prix,
    String? numeroDoc,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (prix != null) updates['prix'] = prix;
      if (numeroDoc != null) updates['numeroDoc'] = numeroDoc;

      await _db.collection('documents').doc(documentId).update(updates);
    } catch (e) {
      print('Erreur lors de la mise à jour du document: $e');
      throw e;
    }
  }

  // Obtenir les documents en attente de validation
  Stream<List<Document>> getDocumentsAValider() {
    return _db
        .collection('documents')
        .where('estValide', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Document.fromJson(doc.data()))
              .toList();
        });
  }
}
