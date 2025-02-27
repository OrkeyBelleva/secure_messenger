import 'package:cloud_firestore/cloud_firestore.dart';

class Membre {
  final String id;
  final String groupeId;
  final String utilisateurId;
  final String role;
  final DateTime dateAjout;
  final DateTime? dateMiseAJour;
  final DateTime? dateRetrait;
  final bool estActif;

  Membre({
    required this.groupeId,
    required this.utilisateurId,
    required this.role,
    required this.dateAjout,
    this.id = '',
    this.dateMiseAJour,
    this.dateRetrait,
    this.estActif = true,
  });

  // Créer une instance à partir d'une Map
  factory Membre.fromMap(Map<String, dynamic> map, String id) {
    return Membre(
      id: id,
      groupeId: map['groupeId'] ?? '',
      utilisateurId: map['utilisateurId'] ?? '',
      role: map['role'] ?? '',
      dateAjout: (map['dateAjout'] as Timestamp).toDate(),
      dateMiseAJour: map['dateMiseAJour'] != null
          ? (map['dateMiseAJour'] as Timestamp).toDate()
          : null,
      dateRetrait: map['dateRetrait'] != null
          ? (map['dateRetrait'] as Timestamp).toDate()
          : null,
      estActif: map['estActif'] ?? true,
    );
  }

  // Convertir l'instance en Map
  Map<String, dynamic> toMap() {
    return {
      'groupeId': groupeId,
      'utilisateurId': utilisateurId,
      'role': role,
      'dateAjout': Timestamp.fromDate(dateAjout),
      'dateMiseAJour': dateMiseAJour != null
          ? Timestamp.fromDate(dateMiseAJour!)
          : null,
      'dateRetrait': dateRetrait != null
          ? Timestamp.fromDate(dateRetrait!)
          : null,
      'estActif': estActif,
    };
  }

  // Créer une copie avec des modifications
  Membre copyWith({
    String? groupeId,
    String? utilisateurId,
    String? role,
    DateTime? dateAjout,
    DateTime? dateMiseAJour,
    DateTime? dateRetrait,
    bool? estActif,
  }) {
    return Membre(
      id: this.id,
      groupeId: groupeId ?? this.groupeId,
      utilisateurId: utilisateurId ?? this.utilisateurId,
      role: role ?? this.role,
      dateAjout: dateAjout ?? this.dateAjout,
      dateMiseAJour: dateMiseAJour ?? this.dateMiseAJour,
      dateRetrait: dateRetrait ?? this.dateRetrait,
      estActif: estActif ?? this.estActif,
    );
  }

  @override
  String toString() {
    return 'Membre{id: $id, groupeId: $groupeId, utilisateurId: $utilisateurId, role: $role}';
  }

  // Vérifier si le membre est administrateur
  bool get estAdministrateur => role == 'administrateur';

  // Vérifier si le membre est modérateur
  bool get estModerateur => role == 'moderateur';

  // Obtenir la durée d'appartenance
  Duration get dureeAppartenance {
    final fin = dateRetrait ?? DateTime.now();
    return fin.difference(dateAjout);
  }
}
