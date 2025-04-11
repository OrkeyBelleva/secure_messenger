import 'package:json_annotation/json_annotation.dart';

part 'utilisateur.g.dart';

@JsonSerializable()
class Utilisateur {
  final String id;
  final String email;
  final String nom;
  final String role;
  final List<String> groupes;
  final DateTime dateCreation;

  Utilisateur({
    required this.id,
    required this.email,
    required this.nom,
    required this.role,
    required this.groupes,
    required this.dateCreation,
  });

  factory Utilisateur.fromJson(Map<String, dynamic> json) =>
      _$UtilisateurFromJson(json);
  Map<String, dynamic> toJson() => _$UtilisateurToJson(this);
}
