import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../services/document_service.dart';
import '../models/utilisateur.dart';

class DocumentsScreen extends StatefulWidget {
  final Utilisateur utilisateur;

  const DocumentsScreen({super.key, required this.utilisateur});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final DocumentService _documentService = DocumentService();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: widget.utilisateur.peutValiderTransaction() ? 2 : 1,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Documents'),
          bottom: TabBar(
            tabs: [
              const Tab(text: 'Mes Documents'),
              if (widget.utilisateur.peutValiderTransaction())
                const Tab(text: 'À Valider'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _construireListeDocuments(),
            if (widget.utilisateur.peutValiderTransaction())
              _construireDocumentsAValider(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _ajouterDocument,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _construireListeDocuments() {
    return StreamBuilder<List<Document>>(
      stream: _documentService.getDocumentsUtilisateur(widget.utilisateur.id),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final documents = snapshot.data!;
        if (documents.isEmpty) {
          return const Center(child: Text('Aucun document'));
        }

        return ListView.builder(
          itemCount: documents.length,
          itemBuilder: (context, index) {
            final doc = documents[index];
            return _construireDocumentTile(doc);
          },
        );
      },
    );
  }

  Widget _construireDocumentsAValider() {
    return StreamBuilder<List<Document>>(
      stream: _documentService.getDocumentsAValider(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final documents = snapshot.data!;
        if (documents.isEmpty) {
          return const Center(child: Text('Aucun document à valider'));
        }

        return ListView.builder(
          itemCount: documents.length,
          itemBuilder: (context, index) {
            final doc = documents[index];
            return _construireDocumentValidationTile(doc);
          },
        );
      },
    );
  }

  Widget _construireDocumentTile(Document document) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: Icon(
          document.type == 'image' ? Icons.image : Icons.insert_drive_file,
          color: document.estValide ? Colors.green : Colors.orange,
        ),
        title: Text(document.nom),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: ${_formatDate(document.date)}'),
            if (document.prix != null)
              Text('Prix: ${document.prix}€'),
            if (document.numeroDoc != null)
              Text('N° Document: ${document.numeroDoc}'),
            Text('Status: ${document.estValide ? 'Validé' : 'En attente'}'),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'voir',
              child: Text('Voir'),
            ),
            const PopupMenuItem(
              value: 'modifier',
              child: Text('Modifier'),
            ),
            const PopupMenuItem(
              value: 'supprimer',
              child: Text('Supprimer'),
            ),
          ],
          onSelected: (value) => _gererAction(value, document),
        ),
        onTap: () => _voirDocument(document),
      ),
    );
  }

  Widget _construireDocumentValidationTile(Document document) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: Icon(
          document.type == 'image' ? Icons.image : Icons.insert_drive_file,
        ),
        title: Text(document.nom),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Propriétaire: ${document.proprietaireId}'),
            Text('Date: ${_formatDate(document.date)}'),
            if (document.prix != null)
              Text('Prix: ${document.prix}€'),
            if (document.numeroDoc != null)
              Text('N° Document: ${document.numeroDoc}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check, color: Colors.green),
              onPressed: () => _validerDocument(document),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () => _refuserDocument(document),
            ),
          ],
        ),
        onTap: () => _voirDocument(document),
      ),
    );
  }

  Future<void> _ajouterDocument() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Prendre une photo'),
            onTap: () {
              Navigator.pop(context);
              _prendrePhoto();
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Choisir une image'),
            onTap: () {
              Navigator.pop(context);
              _choisirImage();
            },
          ),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Télécharger un document'),
            onTap: () {
              Navigator.pop(context);
              _telechargerFichier();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _prendrePhoto() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        await _traiterFichier(File(photo.path), 'image');
      }
    } catch (e) {
      _afficherErreur('Erreur lors de la prise de photo: $e');
    }
  }

  Future<void> _choisirImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        await _traiterFichier(File(image.path), 'image');
      }
    } catch (e) {
      _afficherErreur('Erreur lors du choix de l\'image: $e');
    }
  }

  Future<void> _telechargerFichier() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result != null) {
        final file = File(result.files.single.path!);
        await _traiterFichier(file, 'document');
      }
    } catch (e) {
      _afficherErreur('Erreur lors du choix du fichier: $e');
    }
  }

  Future<void> _traiterFichier(File fichier, String type) async {
    final TextEditingController nomController = TextEditingController();
    final TextEditingController prixController = TextEditingController();
    final TextEditingController numeroController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Informations du document'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nomController,
              decoration: const InputDecoration(labelText: 'Nom du document'),
            ),
            TextField(
              controller: prixController,
              decoration: const InputDecoration(labelText: 'Prix (optionnel)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: numeroController,
              decoration: const InputDecoration(labelText: 'Numéro du document (optionnel)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              if (nomController.text.isEmpty) {
                _afficherErreur('Le nom du document est requis');
                return;
              }
              Navigator.pop(context);
              
              try {
                await _documentService.telechargerDocument(
                  fichier: fichier,
                  nom: nomController.text,
                  type: type,
                  proprietaireId: widget.utilisateur.id,
                  prix: double.tryParse(prixController.text),
                  numeroDoc: numeroController.text.isEmpty ? null : numeroController.text,
                );
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Document téléchargé avec succès')),
                );
              } catch (e) {
                _afficherErreur('Erreur lors du téléchargement: $e');
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  void _voirDocument(Document document) {
    // TODO: Implémenter la visualisation du document
  }

  Future<void> _validerDocument(Document document) async {
    try {
      await _documentService.validerDocument(document.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Document validé')),
      );
    } catch (e) {
      _afficherErreur('Erreur lors de la validation: $e');
    }
  }

  Future<void> _refuserDocument(Document document) async {
    try {
      await _documentService.supprimerDocument(document.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Document refusé et supprimé')),
      );
    } catch (e) {
      _afficherErreur('Erreur lors du refus: $e');
    }
  }

  Future<void> _gererAction(String action, Document document) async {
    switch (action) {
      case 'voir':
        _voirDocument(document);
        break;
      case 'modifier':
        // TODO: Implémenter la modification
        break;
      case 'supprimer':
        await _confirmerSuppression(document);
        break;
    }
  }

  Future<void> _confirmerSuppression(Document document) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Voulez-vous vraiment supprimer ce document ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirme == true) {
      try {
        await _documentService.supprimerDocument(document.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document supprimé')),
        );
      } catch (e) {
        _afficherErreur('Erreur lors de la suppression: $e');
      }
    }
  }

  void _afficherErreur(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
