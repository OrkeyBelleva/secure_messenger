import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../models/piece_jointe.dart';

class PieceJointeService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _uuid = const Uuid();

  // Télécharger une pièce jointe
  Future<PieceJointe> telechargerPieceJointe({
    required File fichier,
    required String expediteurId,
    required String messageId,
  }) async {
    final String extension = path.extension(fichier.path);
    final String nomFichier = '${_uuid.v4()}$extension';
    final String chemin = 'pieces_jointes/$expediteurId/$nomFichier';

    // Créer la référence dans Storage
    final storageRef = _storage.ref().child(chemin);

    // Détecter le type MIME
    final String typeMime = _detecterTypeMime(extension);

    // Télécharger le fichier
    final tache = await storageRef.putFile(
      fichier,
      SettableMetadata(
        contentType: typeMime,
        customMetadata: {
          'expediteurId': expediteurId,
          'messageId': messageId,
          'nomOriginal': path.basename(fichier.path),
        },
      ),
    );

    // Obtenir l'URL de téléchargement
    final url = await tache.ref.getDownloadURL();

    // Créer et retourner l'objet PieceJointe
    return PieceJointe(
      id: nomFichier,
      url: url,
      nom: path.basename(fichier.path),
      type: typeMime,
      taille: await fichier.length(),
      dateCreation: DateTime.now(),
      expediteurId: expediteurId,
      messageId: messageId,
    );
  }

  // Supprimer une pièce jointe
  Future<void> supprimerPieceJointe(PieceJointe pieceJointe) async {
    try {
      final ref = _storage.ref().child(
        'pieces_jointes/${pieceJointe.expediteurId}/${pieceJointe.id}',
      );
      await ref.delete();
    } catch (e) {
      print('Erreur lors de la suppression: $e');
      throw Exception('Impossible de supprimer la pièce jointe');
    }
  }

  // Obtenir l'URL de téléchargement d'une pièce jointe
  Future<String> obtenirUrlTelechargement(String chemin) async {
    try {
      final ref = _storage.ref().child(chemin);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Erreur lors de la récupération de l\'URL: $e');
      throw Exception('Impossible d\'obtenir l\'URL de téléchargement');
    }
  }

  // Détecter le type MIME d'un fichier
  String _detecterTypeMime(String extension) {
    switch (extension.toLowerCase()) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.pdf':
        return 'application/pdf';
      case '.doc':
        return 'application/msword';
      case '.docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case '.xls':
        return 'application/vnd.ms-excel';
      case '.xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case '.txt':
        return 'text/plain';
      default:
        return 'application/octet-stream';
    }
  }

  // Vérifier si un fichier est une image
  bool estImage(String extension) {
    final typeMime = _detecterTypeMime(extension);
    return typeMime.startsWith('image/');
  }

  // Vérifier si un fichier est un document
  bool estDocument(String extension) {
    final typeMime = _detecterTypeMime(extension);
    return typeMime.startsWith('application/');
  }

  // Obtenir la taille maximale autorisée selon le type
  int obtenirTailleMaximale(String extension) {
    if (estImage(extension)) {
      return 5 * 1024 * 1024; // 5 MB pour les images
    } else if (estDocument(extension)) {
      return 10 * 1024 * 1024; // 10 MB pour les documents
    }
    return 2 * 1024 * 1024; // 2 MB par défaut
  }

  // Vérifier si un fichier est autorisé
  bool estFichierAutorise(String extension) {
    final extensionsAutorisees = [
      '.jpg', '.jpeg', '.png', '.gif',
      '.pdf', '.doc', '.docx',
      '.xls', '.xlsx', '.txt'
    ];
    return extensionsAutorisees.contains(extension.toLowerCase());
  }

  // Obtenir les métadonnées d'une pièce jointe
  Future<Map<String, String>> obtenirMetadonnees(String chemin) async {
    try {
      final ref = _storage.ref().child(chemin);
      final metadata = await ref.getMetadata();
      return metadata.customMetadata ?? {};
    } catch (e) {
      print('Erreur lors de la récupération des métadonnées: $e');
      return {};
    }
  }
}
