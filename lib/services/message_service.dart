import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message.dart';
import 'encryption_service.dart';

class MessageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final EncryptionService _encryptionService = EncryptionService();

  Stream<List<Message>> getMessagesGroupe(String groupeId) {
    return _firestore
        .collection('messages')
        .where('groupeId', isEqualTo: groupeId)
        .orderBy('dateEnvoi', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        // Déchiffrer le contenu du message
        data['contenu'] = _encryptionService.decryptMessage(data['contenu']);
        return Message.fromJson(data);
      }).toList();
    });
  }

  Stream<List<Message>> getMessagesPrives(
      String expediteurId, String destinataireId) {
    return _firestore
        .collection('messages')
        .where('expediteurId', whereIn: [expediteurId, destinataireId])
        .where('destinataireId', whereIn: [expediteurId, destinataireId])
        .orderBy('dateEnvoi', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            // Déchiffrer le contenu du message
            data['contenu'] =
                _encryptionService.decryptMessage(data['contenu']);
            return Message.fromJson(data);
          }).toList();
        });
  }

  Future<void> envoyerMessage(Message message) async {
    try {
      // Chiffrer le contenu du message avant l'envoi
      final messageChiffre = Message(
        id: message.id,
        contenu: _encryptionService.encryptMessage(message.contenu),
        expediteurId: message.expediteurId,
        groupeId: message.groupeId,
        destinataireId: message.destinataireId,
        dateEnvoi: message.dateEnvoi,
        fichierJoints: message.fichierJoints,
      );

      await _firestore
          .collection('messages')
          .doc(message.id)
          .set(messageChiffre.toJson());
    } catch (e) {
      print('Erreur lors de l\'envoi du message: $e');
      rethrow;
    }
  }

  Future<void> supprimerMessage(String messageId) async {
    try {
      await _firestore.collection('messages').doc(messageId).delete();
    } catch (e) {
      print('Erreur lors de la suppression du message: $e');
      rethrow;
    }
  }
}
