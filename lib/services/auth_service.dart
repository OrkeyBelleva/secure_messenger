import 'package:firebase_auth/firebase_auth.dart';
import '../models/utilisateur.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Convertir User Firebase en notre modèle Utilisateur
  Utilisateur? _userFromFirebase(User? user) {
    if (user == null) return null;

    return Utilisateur(
      id: user.uid,
      email: user.email ?? '',
      nom: user.displayName ?? '',
      role: 'utilisateur', // Par défaut
      groupes: [],
      dateCreation: DateTime.now(),
    );
  }

  // Stream pour l'état de connexion
  Stream<Utilisateur?> get utilisateur {
    return _auth.authStateChanges().map(_userFromFirebase);
  }

  // Connexion avec email et mot de passe
  Future<Utilisateur?> connexionEmail(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _userFromFirebase(result.user);
    } catch (e) {
      print('Erreur de connexion: $e');
      return null;
    }
  }

  // Inscription avec email et mot de passe
  Future<Utilisateur?> inscription(
      String email, String password, String nom) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Mettre à jour le nom d'affichage
      await result.user?.updateDisplayName(nom);

      return _userFromFirebase(result.user);
    } catch (e) {
      print('Erreur d\'inscription: $e');
      return null;
    }
  }

  // Déconnexion
  Future<void> deconnexion() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Erreur de déconnexion: $e');
    }
  }
}
