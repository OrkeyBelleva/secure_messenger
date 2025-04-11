// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
      id: json['id'] as String,
      contenu: json['contenu'] as String,
      expediteurId: json['expediteurId'] as String,
      groupeId: json['groupeId'] as String?,
      destinataireId: json['destinataireId'] as String?,
      dateEnvoi: DateTime.parse(json['dateEnvoi'] as String),
      fichierJoints: (json['fichierJoints'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      estLu: json['estLu'] as bool? ?? false,
    );

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
      'id': instance.id,
      'contenu': instance.contenu,
      'expediteurId': instance.expediteurId,
      'groupeId': instance.groupeId,
      'destinataireId': instance.destinataireId,
      'dateEnvoi': instance.dateEnvoi.toIso8601String(),
      'fichierJoints': instance.fichierJoints,
      'estLu': instance.estLu,
    };
