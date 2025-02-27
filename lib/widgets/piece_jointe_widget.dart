import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import '../models/piece_jointe.dart';
import '../services/piece_jointe_service.dart';

class PieceJointeWidget extends StatelessWidget {
  final PieceJointe? pieceJointe;
  final Function(PieceJointe)? onPieceJointeSelectionnee;
  final Function()? onSupprimer;
  final bool estMessage;

  const PieceJointeWidget({
    super.key,
    this.pieceJointe,
    this.onPieceJointeSelectionnee,
    this.onSupprimer,
    this.estMessage = true,
  });

  @override
  Widget build(BuildContext context) {
    if (pieceJointe == null) {
      return _construireBoutonAjout(context);
    }
    return _construireApercuPieceJointe(context);
  }

  Widget _construireBoutonAjout(BuildContext context) {
    return InkWell(
      onTap: () => _selectionnerFichier(context),
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 32),
            SizedBox(height: 8),
            Text('Ajouter un fichier'),
          ],
        ),
      ),
    );
  }

  Widget _construireApercuPieceJointe(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 200),
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (pieceJointe!.estImage)
              _construireApercuImage()
            else
              _construireApercuDocument(),
            _construireInfosPieceJointe(context),
          ],
        ),
      ),
    );
  }

  Widget _construireApercuImage() {
    return Stack(
      children: [
        Image.network(
          pieceJointe!.url,
          height: 150,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        if (onSupprimer != null)
          Positioned(
            top: 4,
            right: 4,
            child: IconButton(
              icon: const Icon(Icons.close),
              onPressed: onSupprimer,
              color: Colors.white,
              style: IconButton.styleFrom(
                backgroundColor: Colors.black54,
              ),
            ),
          ),
      ],
    );
  }

  Widget _construireApercuDocument() {
    return Stack(
      children: [
        Container(
          height: 100,
          width: double.infinity,
          color: Colors.grey[200],
          child: Icon(
            _obtenirIconeDocument(),
            size: 48,
            color: Colors.grey[600],
          ),
        ),
        if (onSupprimer != null)
          Positioned(
            top: 4,
            right: 4,
            child: IconButton(
              icon: const Icon(Icons.close),
              onPressed: onSupprimer,
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  Widget _construireInfosPieceJointe(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            pieceJointe!.nom,
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            pieceJointe!.tailleFormatee,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (estMessage) ...[
            const SizedBox(height: 4),
            Text(
              'Envoyé le ${_formaterDate(pieceJointe!.dateCreation)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }

  IconData _obtenirIconeDocument() {
    switch (pieceJointe!.icone) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'word':
        return Icons.description;
      case 'excel':
        return Icons.table_chart;
      case 'text':
        return Icons.text_snippet;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formaterDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }

  Future<void> _selectionnerFichier(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'jpg', 'jpeg', 'png', 'gif',
          'pdf', 'doc', 'docx',
          'xls', 'xlsx', 'txt'
        ],
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        final extension = path.extension(file.path);
        
        // Vérifier si le fichier est autorisé
        final pieceJointeService = PieceJointeService();
        if (!pieceJointeService.estFichierAutorise(extension)) {
          _afficherErreur(context, 'Type de fichier non autorisé');
          return;
        }

        // Vérifier la taille du fichier
        final taille = await file.length();
        final tailleMaximale = pieceJointeService.obtenirTailleMaximale(extension);
        if (taille > tailleMaximale) {
          _afficherErreur(
            context,
            'Fichier trop volumineux (max: ${tailleMaximale ~/ (1024 * 1024)} MB)',
          );
          return;
        }

        // Créer la pièce jointe
        if (onPieceJointeSelectionnee != null) {
          final pieceJointe = await pieceJointeService.telechargerPieceJointe(
            fichier: file,
            expediteurId: 'USER_ID', // À remplacer par l'ID réel
            messageId: 'MESSAGE_ID', // À remplacer par l'ID réel
          );
          onPieceJointeSelectionnee!(pieceJointe);
        }
      }
    } catch (e) {
      _afficherErreur(context, 'Erreur lors de la sélection du fichier');
    }
  }

  void _afficherErreur(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}

// Widget pour afficher une grille de pièces jointes
class GrillePiecesJointes extends StatelessWidget {
  final List<PieceJointe> piecesJointes;
  final Function(PieceJointe)? onSupprimer;
  final bool estMessage;

  const GrillePiecesJointes({
    super.key,
    required this.piecesJointes,
    this.onSupprimer,
    this.estMessage = true,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: piecesJointes.length + (onSupprimer != null ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == piecesJointes.length && onSupprimer != null) {
          return PieceJointeWidget(
            onPieceJointeSelectionnee: (pieceJointe) {
              // Gérer l'ajout
            },
            estMessage: estMessage,
          );
        }
        return PieceJointeWidget(
          pieceJointe: piecesJointes[index],
          onSupprimer: onSupprimer != null
              ? () => onSupprimer!(piecesJointes[index])
              : null,
          estMessage: estMessage,
        );
      },
    );
  }
}
