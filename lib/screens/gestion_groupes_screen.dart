import 'package:flutter/material.dart';
import '../services/groupe_hierarchie_service.dart';
import '../models/groupe.dart';
import '../models/membre.dart';
import '../models/utilisateur.dart';

class GestionGroupesScreen extends StatefulWidget {
  final Utilisateur utilisateur;

  const GestionGroupesScreen({
    super.key,
    required this.utilisateur,
  });

  @override
  State<GestionGroupesScreen> createState() => _GestionGroupesScreenState();
}

class _GestionGroupesScreenState extends State<GestionGroupesScreen> {
  final GroupeHierarchieService _groupeService = GroupeHierarchieService();
  List<Groupe> _groupesSelectionnes = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Groupes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _afficherDialogueNouveauGroupe,
          ),
        ],
      ),
      body: StreamBuilder<List<Groupe>>(
        stream: _groupeService.obtenirGroupesUtilisateur(widget.utilisateur.id),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final groupes = snapshot.data!;
          if (groupes.isEmpty) {
            return const Center(
              child: Text('Aucun groupe trouvé'),
            );
          }

          return ListView.builder(
            itemCount: groupes.length,
            itemBuilder: (context, index) {
              final groupe = groupes[index];
              return _construireCarteGroupe(groupe);
            },
          );
        },
      ),
    );
  }

  Widget _construireCarteGroupe(Groupe groupe) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: ExpansionTile(
        title: Text(groupe.nom),
        subtitle: Text(groupe.description),
        leading: const Icon(Icons.group),
        children: [
          _construireDetailsGroupe(groupe),
        ],
      ),
    );
  }

  Widget _construireDetailsGroupe(Groupe groupe) {
    return Column(
      children: [
        ListTile(
          title: const Text('Membres'),
          trailing: const Icon(Icons.people),
          onTap: () => _afficherMembres(groupe),
        ),
        ListTile(
          title: const Text('Sous-groupes'),
          trailing: const Icon(Icons.account_tree),
          onTap: () => _afficherSousGroupes(groupe),
        ),
        FutureBuilder<String?>(
          future: _groupeService.obtenirRoleUtilisateur(
            groupeId: groupe.id,
            utilisateurId: widget.utilisateur.id,
          ),
          builder: (context, snapshot) {
            final role = snapshot.data;
            if (role == 'administrateur') {
              return OverflowBar(
                children: [
                  TextButton(
                    onPressed: () => _modifierGroupe(groupe),
                    child: const Text('Modifier'),
                  ),
                  TextButton(
                    onPressed: () => _archiverGroupe(groupe),
                    child: Text(
                      groupe.estArchive ? 'Restaurer' : 'Archiver',
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Future<void> _afficherDialogueNouveauGroupe() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const DialogueNouveauGroupe(),
    );

    if (result != null) {
      try {
        await _groupeService.creerGroupe(
          nom: result['nom'],
          description: result['description'],
          createurId: widget.utilisateur.id,
          roles: result['roles'],
          groupeParentId: result['groupeParentId'],
        );
        _afficherSucces('Groupe créé avec succès');
      } catch (e) {
        _afficherErreur('Erreur lors de la création du groupe');
      }
    }
  }

  Future<void> _afficherMembres(Groupe groupe) async {
    final membres = await showDialog<List<Membre>>(
      context: context,
      builder: (context) => DialogueMembres(
        groupe: groupe,
        utilisateurId: widget.utilisateur.id,
      ),
    );

    if (membres != null) {
      setState(() => _groupesSelectionnes = [groupe]);
    }
  }

  Future<void> _afficherSousGroupes(Groupe groupe) async {
    final sousGroupes = await _groupeService.obtenirSousGroupes(groupe.id);
    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (context) => DialogueSousGroupes(
        groupe: groupe,
        sousGroupes: sousGroupes,
      ),
    );
  }

  Future<void> _modifierGroupe(Groupe groupe) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => DialogueModifierGroupe(groupe: groupe),
    );

    if (result != null) {
      try {
        await _groupeService.mettreAJourGroupe(
          groupeId: groupe.id,
          nom: result['nom'],
          description: result['description'],
          roles: result['roles'],
        );
        _afficherSucces('Groupe modifié avec succès');
      } catch (e) {
        _afficherErreur('Erreur lors de la modification du groupe');
      }
    }
  }

  Future<void> _archiverGroupe(Groupe groupe) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          groupe.estArchive ? 'Restaurer le groupe' : 'Archiver le groupe',
        ),
        content: Text(
          groupe.estArchive
              ? 'Voulez-vous restaurer ce groupe ?'
              : 'Voulez-vous archiver ce groupe ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(groupe.estArchive ? 'Restaurer' : 'Archiver'),
          ),
        ],
      ),
    );

    if (confirme == true) {
      try {
        if (groupe.estArchive) {
          await _groupeService.restaurerGroupe(groupe.id);
        } else {
          await _groupeService.archiverGroupe(groupe.id);
        }
        _afficherSucces(
          groupe.estArchive
              ? 'Groupe restauré avec succès'
              : 'Groupe archivé avec succès',
        );
      } catch (e) {
        _afficherErreur(
          'Erreur lors de l\'${groupe.estArchive ? 'restauration' : 'archivage'} du groupe',
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

class DialogueNouveauGroupe extends StatefulWidget {
  const DialogueNouveauGroupe({super.key});

  @override
  State<DialogueNouveauGroupe> createState() => _DialogueNouveauGroupeState();
}

class _DialogueNouveauGroupeState extends State<DialogueNouveauGroupe> {
  final _formKey = GlobalKey<FormState>();
  String _nom = '';
  String _description = '';
  final List<String> _roles = ['membre'];
  String? _groupeParentId;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nouveau Groupe'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Nom du groupe',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer un nom';
                }
                return null;
              },
              onSaved: (value) => _nom = value!,
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Description',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer une description';
                }
                return null;
              },
              onSaved: (value) => _description = value!,
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
        'nom': _nom,
        'description': _description,
        'roles': _roles,
        'groupeParentId': _groupeParentId,
      });
    }
  }
}

class DialogueMembres extends StatelessWidget {
  final Groupe groupe;
  final String utilisateurId;

  const DialogueMembres({
    super.key,
    required this.groupe,
    required this.utilisateurId,
  });

  @override
  Widget build(BuildContext context) {
    final groupeService = GroupeHierarchieService();

    return AlertDialog(
      title: Text('Membres - ${groupe.nom}'),
      content: SizedBox(
        width: double.maxFinite,
        child: StreamBuilder<List<Membre>>(
          stream: groupeService.obtenirMembresGroupe(groupe.id),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Erreur: ${snapshot.error}'));
            }

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final membres = snapshot.data!;
            return ListView.builder(
              shrinkWrap: true,
              itemCount: membres.length,
              itemBuilder: (context, index) {
                final membre = membres[index];
                return ListTile(
                  title: Text('Utilisateur ${membre.utilisateurId}'),
                  subtitle: Text('Rôle: ${membre.role}'),
                  trailing: FutureBuilder<bool>(
                    future: groupeService.verifierPermission(
                      groupeId: groupe.id,
                      utilisateurId: utilisateurId,
                      permission: 'gerer_membres',
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.data == true) {
                        return IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _modifierRole(context, membre),
                        );
                      }
                      return null;
                    },
                  ),
                );
              },
            );
          },
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

  Future<void> _modifierRole(BuildContext context, Membre membre) async {
    final groupeService = GroupeHierarchieService();
    final nouveauRole = await showDialog<String>(
      context: context,
      builder: (context) => DialogueModifierRole(membre: membre),
    );

    if (nouveauRole != null) {
      try {
        await groupeService.mettreAJourRoleMembre(
          groupeId: groupe.id,
          utilisateurId: membre.utilisateurId,
          nouveauRole: nouveauRole,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rôle modifié avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la modification du rôle'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class DialogueModifierRole extends StatefulWidget {
  final Membre membre;

  const DialogueModifierRole({
    super.key,
    required this.membre,
  });

  @override
  State<DialogueModifierRole> createState() => _DialogueModifierRoleState();
}

class _DialogueModifierRoleState extends State<DialogueModifierRole> {
  late String _roleSelectionne;

  @override
  void initState() {
    super.initState();
    _roleSelectionne = widget.membre.role;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Modifier le rôle'),
      content: DropdownButtonFormField<String>(
        value: _roleSelectionne,
        items: ['administrateur', 'moderateur', 'membre', 'invite']
            .map((role) => DropdownMenuItem(
                  value: role,
                  child: Text(role),
                ))
            .toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() => _roleSelectionne = value);
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _roleSelectionne),
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
}

class DialogueSousGroupes extends StatelessWidget {
  final Groupe groupe;
  final List<Groupe> sousGroupes;

  const DialogueSousGroupes({
    super.key,
    required this.groupe,
    required this.sousGroupes,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Sous-groupes - ${groupe.nom}'),
      content: SizedBox(
        width: double.maxFinite,
        child: sousGroupes.isEmpty
            ? const Center(
                child: Text('Aucun sous-groupe'),
              )
            : ListView.builder(
                shrinkWrap: true,
                itemCount: sousGroupes.length,
                itemBuilder: (context, index) {
                  final sousGroupe = sousGroupes[index];
                  return ListTile(
                    title: Text(sousGroupe.nom),
                    subtitle: Text(sousGroupe.description),
                  );
                },
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

class DialogueModifierGroupe extends StatefulWidget {
  final Groupe groupe;

  const DialogueModifierGroupe({
    super.key,
    required this.groupe,
  });

  @override
  State<DialogueModifierGroupe> createState() => _DialogueModifierGroupeState();
}

class _DialogueModifierGroupeState extends State<DialogueModifierGroupe> {
  final _formKey = GlobalKey<FormState>();
  late String _nom;
  late String _description;
  late List<String> _roles;

  @override
  void initState() {
    super.initState();
    _nom = widget.groupe.nom;
    _description = widget.groupe.description;
    _roles = List.from(widget.groupe.roles);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Modifier le groupe'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: _nom,
              decoration: const InputDecoration(
                labelText: 'Nom du groupe',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer un nom';
                }
                return null;
              },
              onSaved: (value) => _nom = value!,
            ),
            TextFormField(
              initialValue: _description,
              decoration: const InputDecoration(
                labelText: 'Description',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer une description';
                }
                return null;
              },
              onSaved: (value) => _description = value!,
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
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }

  void _soumettre() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Navigator.pop(context, {
        'nom': _nom,
        'description': _description,
        'roles': _roles,
      });
    }
  }
}
