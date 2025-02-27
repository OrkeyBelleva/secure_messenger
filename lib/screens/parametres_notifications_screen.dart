import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../models/utilisateur.dart';

class ParametresNotificationsScreen extends StatefulWidget {
  final Utilisateur utilisateur;

  const ParametresNotificationsScreen({
    super.key,
    required this.utilisateur,
  });

  @override
  State<ParametresNotificationsScreen> createState() => _ParametresNotificationsScreenState();
}

class _ParametresNotificationsScreenState extends State<ParametresNotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  bool _notificationsActives = true;
  bool _nouveauxMessages = true;
  bool _validationDocuments = true;
  bool _nouveauxMembres = true;
  bool _sonActive = true;
  bool _vibrationActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _chargerPreferences();
  }

  Future<void> _chargerPreferences() async {
    setState(() => _isLoading = true);
    try {
      // TODO: Charger les préférences depuis Firestore
      setState(() => _isLoading = false);
    } catch (e) {
      _afficherErreur('Erreur lors du chargement des préférences');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres des notifications'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _construireCartePrincipale(),
                  const SizedBox(height: 16),
                  _construireCarteTypes(),
                  const SizedBox(height: 16),
                  _construireCarteSons(),
                  const SizedBox(height: 16),
                  _construireCarteActions(),
                ],
              ),
            ),
    );
  }

  Widget _construireCartePrincipale() {
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Notifications'),
            subtitle: const Text('Activer ou désactiver toutes les notifications'),
            value: _notificationsActives,
            onChanged: (value) {
              setState(() => _notificationsActives = value);
              _sauvegarderPreferences();
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Activez les notifications pour ne manquer aucune mise à jour importante.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _construireCarteTypes() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Types de notifications',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          SwitchListTile(
            title: const Text('Nouveaux messages'),
            subtitle: const Text('Notifications pour les messages reçus'),
            value: _nouveauxMessages && _notificationsActives,
            onChanged: _notificationsActives
                ? (value) {
                    setState(() => _nouveauxMessages = value);
                    _sauvegarderPreferences();
                  }
                : null,
          ),
          SwitchListTile(
            title: const Text('Validation de documents'),
            subtitle: const Text('Notifications pour les validations de documents'),
            value: _validationDocuments && _notificationsActives,
            onChanged: _notificationsActives
                ? (value) {
                    setState(() => _validationDocuments = value);
                    _sauvegarderPreferences();
                  }
                : null,
          ),
          SwitchListTile(
            title: const Text('Nouveaux membres'),
            subtitle: const Text('Notifications pour les nouveaux membres dans les groupes'),
            value: _nouveauxMembres && _notificationsActives,
            onChanged: _notificationsActives
                ? (value) {
                    setState(() => _nouveauxMembres = value);
                    _sauvegarderPreferences();
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _construireCarteSons() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Sons et vibrations',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          SwitchListTile(
            title: const Text('Sons'),
            subtitle: const Text('Activer les sons de notification'),
            value: _sonActive && _notificationsActives,
            onChanged: _notificationsActives
                ? (value) {
                    setState(() => _sonActive = value);
                    _sauvegarderPreferences();
                  }
                : null,
          ),
          SwitchListTile(
            title: const Text('Vibrations'),
            subtitle: const Text('Activer les vibrations'),
            value: _vibrationActive && _notificationsActives,
            onChanged: _notificationsActives
                ? (value) {
                    setState(() => _vibrationActive = value);
                    _sauvegarderPreferences();
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _construireCarteActions() {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Réinitialiser les paramètres'),
            onPressed: _notificationsActives ? _reinitialiserParametres : null,
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Aide sur les notifications'),
            onPressed: _afficherAide,
          ),
        ],
      ),
    );
  }

  Future<void> _sauvegarderPreferences() async {
    setState(() => _isLoading = true);
    try {
      if (!_notificationsActives) {
        await _notificationService.desactiverNotifications(widget.utilisateur.id);
      } else {
        await _notificationService.mettreAJourPreferences(
          widget.utilisateur.id,
          nouveauxMessages: _nouveauxMessages,
          validationDocuments: _validationDocuments,
          nouveauxMembres: _nouveauxMembres,
        );
      }
      setState(() => _isLoading = false);
      _afficherSucces('Préférences sauvegardées');
    } catch (e) {
      setState(() => _isLoading = false);
      _afficherErreur('Erreur lors de la sauvegarde des préférences');
    }
  }

  Future<void> _reinitialiserParametres() async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Réinitialiser les paramètres'),
        content: const Text(
          'Voulez-vous vraiment réinitialiser tous les paramètres de notification ?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Réinitialiser'),
          ),
        ],
      ),
    );

    if (confirme == true) {
      setState(() {
        _notificationsActives = true;
        _nouveauxMessages = true;
        _validationDocuments = true;
        _nouveauxMembres = true;
        _sonActive = true;
        _vibrationActive = true;
      });
      await _sauvegarderPreferences();
    }
  }

  void _afficherAide() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aide sur les notifications'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Types de notifications',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Nouveaux messages : Recevez une notification pour chaque nouveau message'),
              Text('• Validation de documents : Soyez notifié lorsqu\'un document est validé ou refusé'),
              Text('• Nouveaux membres : Recevez une notification lorsqu\'un membre rejoint un groupe'),
              SizedBox(height: 16),
              Text(
                'Sons et vibrations',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Sons : Activez ou désactivez les sons de notification'),
              Text('• Vibrations : Activez ou désactivez les vibrations lors des notifications'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
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
