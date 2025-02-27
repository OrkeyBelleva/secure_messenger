import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message.dart';

class MessageService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Envoyer un message
  Future<void> envoyerMessage(Message message) async {
    try {
      await _db.collection('messages').add(message.toJson());
    } catch (e) {
      print('Erreur d\'envoi du message: $e');
      throw e;
    }
  }

  // Obtenir les messages d'un groupe
  Stream<List<Message>> getMessagesGroupe(String groupeId) {
    return _db
        .collection('messages')
        .where('groupeId', isEqualTo: groupeId)
        .orderBy('dateEnvoi', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Message.fromJson(doc.data()))
              .toList();
        });
  }

  // Obtenir les messages privés entre deux utilisateurs
  Stream<List<Message>> getMessagesPrives(String userId1, String userId2) {
    return _db
        .collection('messages')
        .where('groupeId', isNull: true)
        .where('expediteurId', whereIn: [userId1, userId2])
        .where('destinataireId', whereIn: [userId1, userId2])
        .orderBy('dateEnvoi', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Message.fromJson(doc.data()))
              .toList();
        });
  }

  // Marquer un message comme lu
  Future<void> marquerCommeLu(String messageId) async {
    try {
      await _db.collection('messages').doc(messageId).update({
        'estLu': true,
      });
    } catch (e) {
      print('Erreur lors du marquage du message: $e');
      throw e;
    }
  }

  // Supprimer un message
  Future<void> supprimerMessage(String messageId) async {
    try {
      await _db.collection('messages').doc(messageId).delete();
    } catch (e) {
      print('Erreur lors de la suppression du message: $e');
      throw e;
    }
  }
}
