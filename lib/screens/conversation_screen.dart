import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../models/message.dart';
import '../models/groupe.dart';
import '../models/utilisateur.dart';
import '../services/message_service.dart';

class ConversationScreen extends StatefulWidget {
  final Groupe? groupe;
  final Utilisateur utilisateurActuel;
  final Utilisateur? destinataire;

  const ConversationScreen({
    super.key,
    this.groupe,
    required this.utilisateurActuel,
    this.destinataire,
  });

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final MessageService _messageService = MessageService();
  final TextEditingController _messageController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  bool _envoyerEnCours = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupe?.nom ?? widget.destinataire?.nom ?? 'Conversation'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: _afficherInfos,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: widget.groupe != null
                  ? _messageService.getMessagesGroupe(widget.groupe!.id)
                  : _messageService.getMessagesPrives(
                      widget.utilisateurActuel.id,
                      widget.destinataire!.id,
                    ),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}'));
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!;
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final estEnvoyeur = message.expediteurId == widget.utilisateurActuel.id;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: estEnvoyeur
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.7,
                            ),
                            decoration: BoxDecoration(
                              color: estEnvoyeur ? Colors.blue[100] : Colors.grey[300],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (message.fichierJoints.isNotEmpty)
                                  for (var fichier in message.fichierJoints)
                                    _construirePieceJointe(fichier),
                                Text(message.contenu),
                                const SizedBox(height: 4),
                                Text(
                                  _formatDate(message.dateEnvoi),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          _construireBarreOutils(),
          _construireZoneSaisie(),
        ],
      ),
    );
  }

  Widget _construireBarreOutils() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: _prendrePhoto,
          ),
          IconButton(
            icon: const Icon(Icons.photo),
            onPressed: _choisirImage,
          ),
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: _joindreDocument,
          ),
        ],
      ),
    );
  }

  Widget _construireZoneSaisie() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Écrivez votre message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                ),
              ),
              maxLines: null,
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            onPressed: _envoyerEnCours ? null : _envoyerMessage,
            child: _envoyerEnCours
                ? const CircularProgressIndicator(color: Colors.white)
                : const Icon(Icons.send),
          ),
        ],
      ),
    );
  }

  Widget _construirePieceJointe(String fichier) {
    final estImage = fichier.toLowerCase().endsWith('.jpg') ||
        fichier.toLowerCase().endsWith('.png');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: estImage
          ? Image.network(
              fichier,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            )
          : ListTile(
              leading: const Icon(Icons.insert_drive_file),
              title: Text(fichier.split('/').last),
              onTap: () => _ouvrirFichier(fichier),
            ),
    );
  }

  Future<void> _prendrePhoto() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        // TODO: Implémenter le téléchargement de la photo
      }
    } catch (e) {
      _afficherErreur('Erreur lors de la prise de photo: $e');
    }
  }

  Future<void> _choisirImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        // TODO: Implémenter le téléchargement de l'image
      }
    } catch (e) {
      _afficherErreur('Erreur lors du choix de l\'image: $e');
    }
  }

  Future<void> _joindreDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result != null) {
        // TODO: Implémenter le téléchargement du document
      }
    } catch (e) {
      _afficherErreur('Erreur lors du choix du document: $e');
    }
  }

  Future<void> _envoyerMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    setState(() => _envoyerEnCours = true);

    try {
      final message = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        contenu: _messageController.text.trim(),
        expediteurId: widget.utilisateurActuel.id,
        groupeId: widget.groupe?.id,
        destinataireId: widget.destinataire?.id,
        dateEnvoi: DateTime.now(),
        fichierJoints: [],
      );

      await _messageService.envoyerMessage(message);
      _messageController.clear();
    } catch (e) {
      _afficherErreur('Erreur lors de l\'envoi du message: $e');
    } finally {
      setState(() => _envoyerEnCours = false);
    }
  }

  void _afficherInfos() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Informations'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.groupe != null) ...[
              Text('Nom du groupe: ${widget.groupe!.nom}'),
              Text('Type: ${widget.groupe!.type}'),
              Text('Nombre de membres: ${widget.groupe!.membres.length}'),
            ] else ...[
              Text('Conversation avec: ${widget.destinataire!.nom}'),
              Text('Email: ${widget.destinataire!.email}'),
            ],
          ],
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

  void _afficherErreur(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _ouvrirFichier(String url) {
    // TODO: Implémenter l'ouverture du fichier
  }

  String _formatDate(DateTime date) {
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
