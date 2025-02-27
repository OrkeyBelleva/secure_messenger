import 'package:json_annotation/json_annotation.dart';

part 'groupe.g.dart';

@JsonSerializable()
class Groupe {
  final String id;
  final String nom;
  final String type; // 'achat' ou 'vente'
  final String createurId;
  final List<String> membres;
  final DateTime dateCreation;
  
  Groupe({
    required this.id,
    required this.nom,
    required this.type,
    required this.createurId,
    required this.membres,
    required this.dateCreation,
  });

  factory Groupe.fromJson(Map<String, dynamic> json) => _$GroupeFromJson(json);
  Map<String, dynamic> toJson() => _$GroupeToJson(this);

  bool contientMembre(String userId) {
    return membres.contains(userId);
  }

  bool estGroupeAchat() {
    return type == 'achat';
  }

  bool estGroupeVente() {
    return type == 'vente';
  }
}
