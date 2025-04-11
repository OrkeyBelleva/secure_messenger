// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'groupe.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Groupe _$GroupeFromJson(Map<String, dynamic> json) => Groupe(
      id: json['id'] as String,
      nom: json['nom'] as String,
      type: json['type'] as String,
      createurId: json['createurId'] as String,
      membres:
          (json['membres'] as List<dynamic>).map((e) => e as String).toList(),
      dateCreation: DateTime.parse(json['dateCreation'] as String),
    );

Map<String, dynamic> _$GroupeToJson(Groupe instance) => <String, dynamic>{
      'id': instance.id,
      'nom': instance.nom,
      'type': instance.type,
      'createurId': instance.createurId,
      'membres': instance.membres,
      'dateCreation': instance.dateCreation.toIso8601String(),
    };
