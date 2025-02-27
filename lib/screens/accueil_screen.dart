import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/message_service.dart';
import '../services/groupe_service.dart';
import '../models/utilisateur.dart';
import '../models/groupe.dart';

class AccueilScreen extends StatefulWidget {
  final Utilisateur utilisateur;

  const AccueilScreen({super.key, required this.utilisateur});

  @override
  State<AccueilScreen> createState() => _AccueilScreenState();
}

class _AccueilScreenState extends State<AccueilScreen> {
  final AuthService _authService = AuthService();
  final MessageService _messageService = MessageService();
  final GroupeService _groupeService = GroupeService();
  int _indexSelectionne = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messagerie Sécurisée'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              await _authService.deconnexion();
            },
          ),
        ],
      ),
      body: _construireCorps(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indexSelectionne,
        onTap: (index) => setState(() => _indexSelectionne = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Groupes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Ouvrir la boîte de dialogue pour nouveau message/groupe
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _construireCorps() {
    switch (_indexSelectionne) {
      case 0:
        return _construireListeMessages();
      case 1:
        return _construireListeGroupes();
      case 2:
        return _construireProfil();
      default:
        return const Center(child: Text('Page non trouvée'));
    }
  }

  Widget _construireListeMessages() {
    return StreamBuilder<List<Groupe>>(
      stream: _groupeService.getGroupesUtilisateur(widget.utilisateur.id),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final groupes = snapshot.data!;
        return ListView.builder(
          itemCount: groupes.length,
          itemBuilder: (context, index) {
            final groupe = groupes[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: groupe.estGroupeAchat() ? Colors.blue : Colors.green,
                child: Text(groupe.nom[0]),
              ),
              title: Text(groupe.nom),
              subtitle: Text(groupe.estGroupeAchat() ? 'Groupe Achat' : 'Groupe Vente'),
              onTap: () {
                // TODO: Naviguer vers la conversation du groupe
              },
            );
          },
        );
      },
    );
  }

  Widget _construireListeGroupes() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.shopping_cart),
                  label: const Text('Groupes Achat'),
                  onPressed: () {
                    // TODO: Filtrer les groupes d'achat
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.store),
                  label: const Text('Groupes Vente'),
                  onPressed: () {
                    // TODO: Filtrer les groupes de vente
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Groupe>>(
            stream: _groupeService.getGroupesUtilisateur(widget.utilisateur.id),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Erreur: ${snapshot.error}'));
              }

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final groupes = snapshot.data!;
              return ListView.builder(
                itemCount: groupes.length,
                itemBuilder: (context, index) {
                  final groupe = groupes[index];
                  return ListTile(
                    title: Text(groupe.nom),
                    subtitle: Text('${groupe.membres.length} membres'),
                    trailing: IconButton(
                      icon: const Icon(Icons.settings),
                      onPressed: () {
                        // TODO: Ouvrir les paramètres du groupe
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _construireProfil() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 50,
            child: Icon(Icons.person, size: 50),
          ),
          const SizedBox(height: 16),
          Text('Nom: ${widget.utilisateur.nom}',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text('Email: ${widget.utilisateur.email}',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('Rôle: ${widget.utilisateur.role}',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.edit),
            label: const Text('Modifier le profil'),
            onPressed: () {
              // TODO: Ouvrir l'écran de modification du profil
            },
          ),
        ],
      ),
    );
  }
}
