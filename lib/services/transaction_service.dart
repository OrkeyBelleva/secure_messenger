import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction.dart';
import '../models/utilisateur.dart';

class TransactionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Créer une nouvelle transaction
  Future<String> creerTransaction({
    required String expediteurId,
    required String destinataireId,
    required String type,
    required String statut,
    required Map<String, dynamic> details,
    required List<String> documentsAssocies,
  }) async {
    final transaction = Transaction(
      id: '',
      expediteurId: expediteurId,
      destinataireId: destinataireId,
      type: type,
      statut: statut,
      details: details,
      documentsAssocies: documentsAssocies,
      dateCreation: DateTime.now(),
      dateMiseAJour: DateTime.now(),
    );

    final docRef = await _db.collection('transactions').add(transaction.toMap());
    return docRef.id;
  }

  // Mettre à jour le statut d'une transaction
  Future<void> mettreAJourStatut({
    required String transactionId,
    required String nouveauStatut,
    String? commentaire,
  }) async {
    await _db.collection('transactions').doc(transactionId).update({
      'statut': nouveauStatut,
      'dateMiseAJour': FieldValue.serverTimestamp(),
      if (commentaire != null) 'commentaire': commentaire,
    });
  }

  // Obtenir les transactions d'un utilisateur
  Stream<List<Transaction>> obtenirTransactionsUtilisateur(String userId) {
    return _db
        .collection('transactions')
        .where('expediteurId', isEqualTo: userId)
        .orderBy('dateCreation', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Transaction.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Obtenir les transactions en attente pour validation
  Stream<List<Transaction>> obtenirTransactionsEnAttente(String validateurId) {
    return _db
        .collection('transactions')
        .where('destinataireId', isEqualTo: validateurId)
        .where('statut', isEqualTo: 'en_attente')
        .orderBy('dateCreation', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Transaction.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Valider une transaction
  Future<void> validerTransaction({
    required String transactionId,
    required String validateurId,
    required bool estApprouve,
    String? commentaire,
  }) async {
    final statut = estApprouve ? 'approuve' : 'refuse';
    
    await _db.runTransaction((transaction) async {
      final transactionRef = _db.collection('transactions').doc(transactionId);
      final transactionDoc = await transaction.get(transactionRef);

      if (!transactionDoc.exists) {
        throw Exception('Transaction non trouvée');
      }

      transaction.update(transactionRef, {
        'statut': statut,
        'validateurId': validateurId,
        'dateValidation': FieldValue.serverTimestamp(),
        if (commentaire != null) 'commentaireValidation': commentaire,
      });
    });
  }

  // Ajouter un document à une transaction
  Future<void> ajouterDocument({
    required String transactionId,
    required String documentId,
  }) async {
    await _db.collection('transactions').doc(transactionId).update({
      'documentsAssocies': FieldValue.arrayUnion([documentId]),
      'dateMiseAJour': FieldValue.serverTimestamp(),
    });
  }

  // Supprimer un document d'une transaction
  Future<void> supprimerDocument({
    required String transactionId,
    required String documentId,
  }) async {
    await _db.collection('transactions').doc(transactionId).update({
      'documentsAssocies': FieldValue.arrayRemove([documentId]),
      'dateMiseAJour': FieldValue.serverTimestamp(),
    });
  }

  // Obtenir les statistiques des transactions
  Future<Map<String, dynamic>> obtenirStatistiques(String userId) async {
    final querySnapshot = await _db
        .collection('transactions')
        .where('expediteurId', isEqualTo: userId)
        .get();

    final transactions = querySnapshot.docs
        .map((doc) => Transaction.fromMap(doc.data(), doc.id))
        .toList();

    int total = transactions.length;
    int approuvees = transactions.where((t) => t.statut == 'approuve').length;
    int refusees = transactions.where((t) => t.statut == 'refuse').length;
    int enAttente = transactions.where((t) => t.statut == 'en_attente').length;

    return {
      'total': total,
      'approuvees': approuvees,
      'refusees': refusees,
      'enAttente': enAttente,
      'tauxApprobation': total > 0 ? (approuvees / total * 100).round() : 0,
    };
  }

  // Rechercher des transactions
  Future<List<Transaction>> rechercherTransactions({
    String? expediteurId,
    String? destinataireId,
    String? type,
    String? statut,
    DateTime? dateDebut,
    DateTime? dateFin,
  }) async {
    Query query = _db.collection('transactions');

    if (expediteurId != null) {
      query = query.where('expediteurId', isEqualTo: expediteurId);
    }
    if (destinataireId != null) {
      query = query.where('destinataireId', isEqualTo: destinataireId);
    }
    if (type != null) {
      query = query.where('type', isEqualTo: type);
    }
    if (statut != null) {
      query = query.where('statut', isEqualTo: statut);
    }
    if (dateDebut != null) {
      query = query.where('dateCreation', isGreaterThanOrEqualTo: dateDebut);
    }
    if (dateFin != null) {
      query = query.where('dateCreation', isLessThanOrEqualTo: dateFin);
    }

    final querySnapshot = await query.get();
    return querySnapshot.docs
        .map((doc) => Transaction.fromMap(doc.data(), doc.id))
        .toList();
  }
}
