// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'utilisateur.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Utilisateur _$UtilisateurFromJson(Map<String, dynamic> json) => Utilisateur(
      id: json['id'] as String,
      email: json['email'] as String,
      nom: json['nom'] as String,
      role: json['role'] as String,
      groupes:
          (json['groupes'] as List<dynamic>).map((e) => e as String).toList(),
      dateCreation: DateTime.parse(json['dateCreation'] as String),
    );

Map<String, dynamic> _$UtilisateurToJson(Utilisateur instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'nom': instance.nom,
      'role': instance.role,
      'groupes': instance.groupes,
      'dateCreation': instance.dateCreation.toIso8601String(),
    };
