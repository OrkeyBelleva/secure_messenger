class Role {
  final String nom;
  final List<String> permissions;
  final String description;
  final int niveau;

  Role({
    required this.nom,
    required this.permissions,
    required this.description,
    required this.niveau,
  });

  // Créer une instance à partir d'une Map
  factory Role.fromMap(Map<String, dynamic> map) {
    return Role(
      nom: map['nom'] ?? '',
      permissions: List<String>.from(map['permissions'] ?? []),
      description: map['description'] ?? '',
      niveau: map['niveau'] ?? 0,
    );
  }

  // Convertir l'instance en Map
  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'permissions': permissions,
      'description': description,
      'niveau': niveau,
    };
  }

  // Rôles prédéfinis
  static Role administrateur() {
    return Role(
      nom: 'administrateur',
      permissions: [
        'gerer_membres',
        'gerer_roles',
        'gerer_messages',
        'gerer_documents',
        'gerer_sous_groupes',
        'archiver_groupe',
        'supprimer_messages',
        'bannir_membres',
      ],
      description: 'Contrôle total sur le groupe',
      niveau: 3,
    );
  }

  static Role moderateur() {
    return Role(
      nom: 'moderateur',
      permissions: [
        'gerer_messages',
        'gerer_documents',
        'supprimer_messages',
        'avertir_membres',
      ],
      description: 'Modération des contenus et des membres',
      niveau: 2,
    );
  }

  static Role membre() {
    return Role(
      nom: 'membre',
      permissions: [
        'envoyer_messages',
        'voir_documents',
        'telecharger_documents',
      ],
      description: 'Participation aux discussions et accès aux documents',
      niveau: 1,
    );
  }

  static Role invite() {
    return Role(
      nom: 'invite',
      permissions: [
        'voir_messages',
        'voir_documents',
      ],
      description: 'Accès en lecture seule',
      niveau: 0,
    );
  }

  // Vérifier si le rôle a une permission spécifique
  bool hasPermission(String permission) {
    return permissions.contains(permission);
  }

  // Vérifier si le rôle est supérieur à un autre rôle
  bool estSuperieurA(Role autreRole) {
    return niveau > autreRole.niveau;
  }

  // Vérifier si le rôle peut gérer un autre rôle
  bool peutGerer(Role autreRole) {
    return niveau > autreRole.niveau && hasPermission('gerer_roles');
  }

  @override
  String toString() {
    return 'Role{nom: $nom, niveau: $niveau}';
  }
}
