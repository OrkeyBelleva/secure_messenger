class Transaction {
  final String id;
  final String expediteurId;
  final String destinataireId;
  final String type;
  final String statut;
  final Map<String, dynamic> details;
  final List<String> documentsAssocies;
  final DateTime dateCreation;
  final DateTime dateMiseAJour;
  final String? validateurId;
  final DateTime? dateValidation;
  final String? commentaireValidation;

  Transaction({
    required this.id,
    required this.expediteurId,
    required this.destinataireId,
    required this.type,
    required this.statut,
    required this.details,
    required this.documentsAssocies,
    required this.dateCreation,
    required this.dateMiseAJour,
    this.validateurId,
    this.dateValidation,
    this.commentaireValidation,
  });

  // Créer une instance à partir d'une Map
  factory Transaction.fromMap(Map<String, dynamic> map, String id) {
    return Transaction(
      id: id,
      expediteurId: map['expediteurId'] ?? '',
      destinataireId: map['destinataireId'] ?? '',
      type: map['type'] ?? '',
      statut: map['statut'] ?? '',
      details: Map<String, dynamic>.from(map['details'] ?? {}),
      documentsAssocies: List<String>.from(map['documentsAssocies'] ?? []),
      dateCreation: (map['dateCreation'] as Timestamp).toDate(),
      dateMiseAJour: (map['dateMiseAJour'] as Timestamp).toDate(),
      validateurId: map['validateurId'],
      dateValidation: map['dateValidation'] != null
          ? (map['dateValidation'] as Timestamp).toDate()
          : null,
      commentaireValidation: map['commentaireValidation'],
    );
  }

  // Convertir l'instance en Map
  Map<String, dynamic> toMap() {
    return {
      'expediteurId': expediteurId,
      'destinataireId': destinataireId,
      'type': type,
      'statut': statut,
      'details': details,
      'documentsAssocies': documentsAssocies,
      'dateCreation': Timestamp.fromDate(dateCreation),
      'dateMiseAJour': Timestamp.fromDate(dateMiseAJour),
      'validateurId': validateurId,
      'dateValidation':
          dateValidation != null ? Timestamp.fromDate(dateValidation!) : null,
      'commentaireValidation': commentaireValidation,
    };
  }

  // Créer une copie avec des modifications
  Transaction copyWith({
    String? expediteurId,
    String? destinataireId,
    String? type,
    String? statut,
    Map<String, dynamic>? details,
    List<String>? documentsAssocies,
    DateTime? dateCreation,
    DateTime? dateMiseAJour,
    String? validateurId,
    DateTime? dateValidation,
    String? commentaireValidation,
  }) {
    return Transaction(
      id: id,
      expediteurId: expediteurId ?? this.expediteurId,
      destinataireId: destinataireId ?? this.destinataireId,
      type: type ?? this.type,
      statut: statut ?? this.statut,
      details: details ?? this.details,
      documentsAssocies: documentsAssocies ?? this.documentsAssocies,
      dateCreation: dateCreation ?? this.dateCreation,
      dateMiseAJour: dateMiseAJour ?? this.dateMiseAJour,
      validateurId: validateurId ?? this.validateurId,
      dateValidation: dateValidation ?? this.dateValidation,
      commentaireValidation:
          commentaireValidation ?? this.commentaireValidation,
    );
  }

  @override
  String toString() {
    return 'Transaction{id: $id, type: $type, statut: $statut}';
  }

  // Vérifier si la transaction est en attente
  bool get estEnAttente => statut == 'en_attente';

  // Vérifier si la transaction est approuvée
  bool get estApprouvee => statut == 'approuve';

  // Vérifier si la transaction est refusée
  bool get estRefusee => statut == 'refuse';

  // Obtenir la durée depuis la création
  Duration get dureeSoumission {
    return DateTime.now().difference(dateCreation);
  }

  // Obtenir la durée de validation
  Duration? get dureeValidation {
    if (dateValidation == null) return null;
    return dateValidation!.difference(dateCreation);
  }
}
