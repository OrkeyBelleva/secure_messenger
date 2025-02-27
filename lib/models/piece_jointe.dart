class PieceJointe {
  final String id;
  final String url;
  final String nom;
  final String type;
  final int taille;
  final DateTime dateCreation;
  final String expediteurId;
  final String messageId;

  PieceJointe({
    required this.id,
    required this.url,
    required this.nom,
    required this.type,
    required this.taille,
    required this.dateCreation,
    required this.expediteurId,
    required this.messageId,
  });

  // Créer une instance à partir d'une Map
  factory PieceJointe.fromMap(Map<String, dynamic> map) {
    return PieceJointe(
      id: map['id'] ?? '',
      url: map['url'] ?? '',
      nom: map['nom'] ?? '',
      type: map['type'] ?? '',
      taille: map['taille'] ?? 0,
      dateCreation: DateTime.fromMillisecondsSinceEpoch(map['dateCreation'] ?? 0),
      expediteurId: map['expediteurId'] ?? '',
      messageId: map['messageId'] ?? '',
    );
  }

  // Convertir l'instance en Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'url': url,
      'nom': nom,
      'type': type,
      'taille': taille,
      'dateCreation': dateCreation.millisecondsSinceEpoch,
      'expediteurId': expediteurId,
      'messageId': messageId,
    };
  }

  // Obtenir la taille formatée
  String get tailleFormatee {
    if (taille < 1024) {
      return '$taille B';
    } else if (taille < 1024 * 1024) {
      return '${(taille / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(taille / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  // Vérifier si c'est une image
  bool get estImage => type.startsWith('image/');

  // Vérifier si c'est un document
  bool get estDocument => type.startsWith('application/');

  // Obtenir l'icône appropriée selon le type
  String get icone {
    if (estImage) {
      return 'image';
    } else if (type.contains('pdf')) {
      return 'pdf';
    } else if (type.contains('word') || type.contains('doc')) {
      return 'word';
    } else if (type.contains('excel') || type.contains('sheet')) {
      return 'excel';
    } else if (type.contains('text')) {
      return 'text';
    }
    return 'file';
  }

  @override
  String toString() {
    return 'PieceJointe{id: $id, nom: $nom, type: $type}';
  }
}
