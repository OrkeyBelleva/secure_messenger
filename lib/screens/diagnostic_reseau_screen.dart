import 'package:flutter/material.dart';
import '../services/reseau_local_service.dart';

class DiagnosticReseauScreen extends StatefulWidget {
  const DiagnosticReseauScreen({super.key});

  @override
  State<DiagnosticReseauScreen> createState() => _DiagnosticReseauScreenState();
}

class _DiagnosticReseauScreenState extends State<DiagnosticReseauScreen> {
  Map<String, dynamic> _statistiques = {};
  bool _enChargement = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _rafraichirStatistiques();
    // Rafraîchir les statistiques toutes les 5 secondes
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      _rafraichirStatistiques();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _rafraichirStatistiques() async {
    if (_enChargement) return;
    
    setState(() => _enChargement = true);
    try {
      final stats = await ReseauLocalService.obtenirStatistiquesReseau();
      setState(() => _statistiques = stats);
    } catch (e) {
      print('Erreur lors de la récupération des statistiques: $e');
    } finally {
      setState(() => _enChargement = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnostic Réseau'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _rafraichirStatistiques,
          ),
        ],
      ),
      body: _enChargement
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _construireCarteStatut(),
                  const SizedBox(height: 16),
                  _construireCarteConnectivite(),
                  const SizedBox(height: 16),
                  _construireCarteActions(),
                ],
              ),
            ),
    );
  }

  Widget _construireCarteStatut() {
    final connecte = _statistiques['connecte'] ?? false;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  connecte ? Icons.check_circle : Icons.error,
                  color: connecte ? Colors.green : Colors.red,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Statut: ${connecte ? 'Connecté' : 'Déconnecté'}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Adresse IP: ${_statistiques['adresseIP'] ?? 'Non disponible'}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Dernière mise à jour: ${_statistiques['timestamp'] ?? 'Jamais'}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _construireCarteConnectivite() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tests de connectivité',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.router),
              title: const Text('Hôte par défaut'),
              subtitle: Text(ReseauLocalService.HOST_PAR_DEFAUT),
              trailing: FutureBuilder<bool>(
                future: ReseauLocalService.verifierHoteAccessible(
                  ReseauLocalService.HOST_PAR_DEFAUT,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  }
                  return Icon(
                    snapshot.data == true ? Icons.check : Icons.close,
                    color: snapshot.data == true ? Colors.green : Colors.red,
                  );
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.storage),
              title: const Text('Cache local'),
              subtitle: const Text('50 MB alloués'),
              trailing: const Icon(Icons.check, color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construireCarteActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Reconfigurer le cache'),
              onTap: () async {
                try {
                  await ReseauLocalService.configurerCache();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cache reconfiguré avec succès')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur: $e')),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.sync),
              title: const Text('Optimiser la synchronisation'),
              onTap: () async {
                try {
                  await ReseauLocalService.optimiserSynchronisation();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Synchronisation optimisée avec succès'),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur: $e')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
