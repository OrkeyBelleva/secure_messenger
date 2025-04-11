import 'package:flutter/material.dart';
import '../services/transaction_service.dart';
import '../models/transaction.dart';
import '../models/utilisateur.dart';

class GestionTransactionsScreen extends StatefulWidget {
  final Utilisateur utilisateur;

  const GestionTransactionsScreen({
    super.key,
    required this.utilisateur,
  });

  @override
  State<GestionTransactionsScreen> createState() =>
      _GestionTransactionsScreenState();
}

class _GestionTransactionsScreenState extends State<GestionTransactionsScreen>
    with SingleTickerProviderStateMixin {
  final TransactionService _transactionService = TransactionService();
  late TabController _tabController;
  Map<String, dynamic> _statistiques = {};
  bool _chargementStats = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _chargerStatistiques();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _chargerStatistiques() async {
    setState(() => _chargementStats = true);
    try {
      final stats = await _transactionService.obtenirStatistiques(
        widget.utilisateur.id,
      );
      setState(() => _statistiques = stats);
    } catch (e) {
      _afficherErreur('Erreur lors du chargement des statistiques');
    } finally {
      setState(() => _chargementStats = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Transactions'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Mes Transactions'),
            Tab(text: 'À Valider'),
          ],
        ),
      ),
      body: Column(
        children: [
          _construireCarteStatistiques(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _construireListeTransactions(),
                _construireListeValidations(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _afficherDialogueNouvelleTransaction,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _construireCarteStatistiques() {
    if (_chargementStats) {
      return const Center(child: CircularProgressIndicator());
    }

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _construireStatistique(
              'Total',
              _statistiques['total']?.toString() ?? '0',
              Colors.blue,
            ),
            _construireStatistique(
              'Approuvées',
              _statistiques['approuvees']?.toString() ?? '0',
              Colors.green,
            ),
            _construireStatistique(
              'En attente',
              _statistiques['enAttente']?.toString() ?? '0',
              Colors.orange,
            ),
            _construireStatistique(
              'Refusées',
              _statistiques['refusees']?.toString() ?? '0',
              Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _construireStatistique(String label, String valeur, Color couleur) {
    return Column(
      children: [
        Text(
          valeur,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: couleur,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _construireListeTransactions() {
    return StreamBuilder<List<Transaction>>(
      stream: _transactionService.obtenirTransactionsUtilisateur(
        widget.utilisateur.id,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final transactions = snapshot.data!;
        if (transactions.isEmpty) {
          return const Center(
            child: Text('Aucune transaction trouvée'),
          );
        }

        return ListView.builder(
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final transaction = transactions[index];
            return _construireCarteTransaction(transaction);
          },
        );
      },
    );
  }

  Widget _construireListeValidations() {
    return StreamBuilder<List<Transaction>>(
      stream: _transactionService.obtenirTransactionsEnAttente(
        widget.utilisateur.id,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final transactions = snapshot.data!;
        if (transactions.isEmpty) {
          return const Center(
            child: Text('Aucune transaction à valider'),
          );
        }

        return ListView.builder(
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final transaction = transactions[index];
            return _construireCarteValidation(transaction);
          },
        );
      },
    );
  }

  Widget _construireCarteTransaction(Transaction transaction) {
    Color couleurStatut;
    IconData iconeStatut;

    switch (transaction.statut) {
      case 'approuve':
        couleurStatut = Colors.green;
        iconeStatut = Icons.check_circle;
        break;
      case 'refuse':
        couleurStatut = Colors.red;
        iconeStatut = Icons.cancel;
        break;
      default:
        couleurStatut = Colors.orange;
        iconeStatut = Icons.pending;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: ListTile(
        leading: Icon(iconeStatut, color: couleurStatut),
        title: Text('Transaction ${transaction.id}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${transaction.type}'),
            Text(
              'Date: ${transaction.dateCreation.toLocal().toString().split('.')[0]}',
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => _afficherDetailsTransaction(transaction),
        ),
      ),
    );
  }

  Widget _construireCarteValidation(Transaction transaction) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Column(
        children: [
          ListTile(
            title: Text('Transaction ${transaction.id}'),
            subtitle: Text('Type: ${transaction.type}'),
          ),
          OverflowBar(
            children: [
              TextButton(
                onPressed: () => _afficherDetailsTransaction(transaction),
                child: const Text('Détails'),
              ),
              ElevatedButton(
                onPressed: () => _validerTransaction(transaction, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text('Approuver'),
              ),
              ElevatedButton(
                onPressed: () => _validerTransaction(transaction, false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Refuser'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _afficherDialogueNouvelleTransaction() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const DialogueNouvelleTransaction(),
    );

    if (result != null) {
      try {
        await _transactionService.creerTransaction(
          expediteurId: widget.utilisateur.id,
          destinataireId: result['destinataireId'],
          type: result['type'],
          statut: 'en_attente',
          details: result['details'],
          documentsAssocies: result['documentsAssocies'],
        );
        _afficherSucces('Transaction créée avec succès');
      } catch (e) {
        _afficherErreur('Erreur lors de la création de la transaction');
      }
    }
  }

  Future<void> _afficherDetailsTransaction(Transaction transaction) async {
    await showDialog(
      context: context,
      builder: (context) => DialogueDetailsTransaction(
        transaction: transaction,
      ),
    );
  }

  Future<void> _validerTransaction(
    Transaction transaction,
    bool estApprouve,
  ) async {
    final commentaire = await showDialog<String>(
      context: context,
      builder: (context) => DialogueCommentaire(
        titre:
            estApprouve ? 'Approuver la transaction' : 'Refuser la transaction',
      ),
    );

    if (commentaire != null) {
      try {
        await _transactionService.validerTransaction(
          transactionId: transaction.id,
          validateurId: widget.utilisateur.id,
          estApprouve: estApprouve,
          commentaire: commentaire,
        );
        _afficherSucces('Transaction ${estApprouve ? 'approuvée' : 'refusée'}');
      } catch (e) {
        _afficherErreur(
          'Erreur lors de la validation de la transaction',
        );
      }
    }
  }

  void _afficherSucces(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _afficherErreur(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}

class DialogueNouvelleTransaction extends StatefulWidget {
  const DialogueNouvelleTransaction({super.key});

  @override
  State<DialogueNouvelleTransaction> createState() =>
      _DialogueNouvelleTransactionState();
}

class _DialogueNouvelleTransactionState
    extends State<DialogueNouvelleTransaction> {
  final _formKey = GlobalKey<FormState>();
  String _destinataireId = '';
  String _type = '';
  final Map<String, dynamic> _details = {};
  final List<String> _documentsAssocies = [];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nouvelle Transaction'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'ID du destinataire',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer l\'ID du destinataire';
                }
                return null;
              },
              onSaved: (value) => _destinataireId = value!,
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Type de transaction',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer le type de transaction';
                }
                return null;
              },
              onSaved: (value) => _type = value!,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _soumettre,
          child: const Text('Créer'),
        ),
      ],
    );
  }

  void _soumettre() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Navigator.pop(context, {
        'destinataireId': _destinataireId,
        'type': _type,
        'details': _details,
        'documentsAssocies': _documentsAssocies,
      });
    }
  }
}

class DialogueDetailsTransaction extends StatelessWidget {
  final Transaction transaction;

  const DialogueDetailsTransaction({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Transaction ${transaction.id}'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${transaction.type}'),
            Text('Statut: ${transaction.statut}'),
            Text(
              'Date de création: ${transaction.dateCreation.toLocal().toString().split('.')[0]}',
            ),
            Text(
              'Dernière mise à jour: ${transaction.dateMiseAJour.toLocal().toString().split('.')[0]}',
            ),
            if (transaction.validateurId != null)
              Text('Validateur: ${transaction.validateurId}'),
            if (transaction.dateValidation != null)
              Text(
                'Date de validation: ${transaction.dateValidation!.toLocal().toString().split('.')[0]}',
              ),
            if (transaction.commentaireValidation != null)
              Text('Commentaire: ${transaction.commentaireValidation}'),
            const SizedBox(height: 16),
            Text('Documents associés: ${transaction.documentsAssocies.length}'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fermer'),
        ),
      ],
    );
  }
}

class DialogueCommentaire extends StatefulWidget {
  final String titre;

  const DialogueCommentaire({
    super.key,
    required this.titre,
  });

  @override
  State<DialogueCommentaire> createState() => _DialogueCommentaireState();
}

class _DialogueCommentaireState extends State<DialogueCommentaire> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.titre),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          labelText: 'Commentaire',
          hintText: 'Ajouter un commentaire (optionnel)',
        ),
        maxLines: 3,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('Valider'),
        ),
      ],
    );
  }
}
