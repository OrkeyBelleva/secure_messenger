import 'package:flutter/material.dart';
import '../services/utilisateur_service.dart';
import '../models/utilisateur.dart';

class GestionUtilisateursScreen extends StatefulWidget {
  final Utilisateur utilisateurActuel;

  const GestionUtilisateursScreen({
    super.key,
    required this.utilisateurActuel,
  });

  @override
  State<GestionUtilisateursScreen> createState() => _GestionUtilisateursScreenState();
}

class _GestionUtilisateursScreenState extends State<GestionUtilisateursScreen> {
  final UtilisateurService _utilisateurService = UtilisateurService();
  final TextEditingController _rechercheController = TextEditingController();
  String? _roleFiltre;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Utilisateurs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _afficherFiltres,
          ),
        ],
      ),
      body: Column(
        children: [
          _construireBarreRecherche(),
          Expanded(
            child: StreamBuilder<List<Utilisateur>>(
              stream: _utilisateurService.getTousLesUtilisateurs(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}'));
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var utilisateurs = snapshot.data!;

                // Appliquer les filtres
                if (_roleFiltre != null) {
                  utilisateurs = utilisateurs
                      .where((u) => u.role == _roleFiltre)
                      .toList();
                }

                if (_rechercheController.text.isNotEmpty) {
                  final recherche = _rechercheController.text.toLowerCase();
                  utilisateurs = utilisateurs
                      .where((u) => 
                          u.nom.toLowerCase().contains(recherche) ||
                          u.email.toLowerCase().contains(recherche))
                      .toList();
                }

                if (utilisateurs.isEmpty) {
                  return const Center(
                    child: Text('Aucun utilisateur trouvé'),
                  );
                }

                return ListView.builder(
                  itemCount: utilisateurs.length,
                  itemBuilder: (context, index) {
                    final utilisateur = utilisateurs[index];
                    return _construireUtilisateurCard(utilisateur);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _construireBarreRecherche() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _rechercheController,
        decoration: InputDecoration(
          hintText: 'Rechercher un utilisateur...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _rechercheController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _rechercheController.clear();
                    setState(() {});
                  },
                )
              : null,
          border: const OutlineInputBorder(),
        ),
        onChanged: (value) => setState(() {}),
      ),
    );
  }

  Widget _construireUtilisateurCard(Utilisateur utilisateur) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: ExpansionTile(
        leading: CircleAvatar(
          child: Text(utilisateur.nom[0]),
        ),
        title: Text(utilisateur.nom),
        subtitle: Text(utilisateur.email),
        trailing: _construireBadgeRole(utilisateur.role),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Permissions :',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: (Role.permissions[utilisateur.role] ?? [])
                      .map((permission) => Chip(
                            label: Text(permission),
                            backgroundColor: Colors.blue[100],
                          ))
                      .toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text('Modifier le rôle'),
                      onPressed: () => _modifierRole(utilisateur),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.block),
                      label: const Text('Désactiver'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () => _desactiverCompte(utilisateur),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                FutureBuilder<Map<String, dynamic>>(
                  future: _utilisateurService.getStatistiquesUtilisateur(utilisateur.id),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }
                    final stats = snapshot.data!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Statistiques :',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text('Messages envoyés : ${stats['nombreMessages']}'),
                        Text('Documents : ${stats['nombreDocuments']}'),
                        Text('Groupes : ${stats['nombreGroupes']}'),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _construireBadgeRole(String role) {
    Color couleur;
    switch (role) {
      case 'administrateur':
        couleur = Colors.red;
        break;
      case 'moderateur':
        couleur = Colors.orange;
        break;
      default:
        couleur = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: couleur,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        role,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  void _afficherFiltres() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrer par rôle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...Role.tousLesRoles.map((role) => RadioListTile<String>(
              title: Text(role),
              value: role,
              groupValue: _roleFiltre,
              onChanged: (value) {
                setState(() => _roleFiltre = value);
                Navigator.pop(context);
              },
            )),
            RadioListTile<String>(
              title: const Text('Tous les rôles'),
              value: null,
              groupValue: _roleFiltre,
              onChanged: (value) {
                setState(() => _roleFiltre = value);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _modifierRole(Utilisateur utilisateur) async {
    final nouveauRole = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier le rôle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: Role.tousLesRoles
              .map((role) => RadioListTile<String>(
                    title: Text(role),
                    value: role,
                    groupValue: utilisateur.role,
                    onChanged: (value) => Navigator.pop(context, value),
                  ))
              .toList(),
        ),
      ),
    );

    if (nouveauRole != null && nouveauRole != utilisateur.role) {
      try {
        await _utilisateurService.mettreAJourRole(
          utilisateur.id,
          nouveauRole,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rôle mis à jour avec succès')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _desactiverCompte(Utilisateur utilisateur) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la désactivation'),
        content: Text(
          'Voulez-vous vraiment désactiver le compte de ${utilisateur.nom} ?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Désactiver'),
          ),
        ],
      ),
    );

    if (confirme == true) {
      try {
        await _utilisateurService.desactiverCompte(utilisateur.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Compte désactivé avec succès')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _rechercheController.dispose();
    super.dispose();
  }
}
