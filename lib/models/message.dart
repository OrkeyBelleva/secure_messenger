import 'package:json_annotation/json_annotation.dart';

part 'message.g.dart';

@JsonSerializable()
class Message {
  final String id;
  final String contenu;
  final String expediteurId;
  final String? groupeId;
  final String? destinataireId;
  final DateTime dateEnvoi;
  final List<String> fichierJoints;
  final bool estLu;
  
  Message({
    required this.id,
    required this.contenu,
    required this.expediteurId,
    this.groupeId,
    this.destinataireId,
    required this.dateEnvoi,
    required this.fichierJoints,
    this.estLu = false,
  });

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);
  Map<String, dynamic> toJson() => _$MessageToJson(this);

  bool estMessageGroupe() {
    return groupeId != null;
  }

  bool estMessagePrive() {
    return destinataireId != null;
  }
}
