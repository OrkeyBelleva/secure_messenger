import 'package:flutter/foundation.dart';
import '../models/utilisateur.dart';
import '../services/auth_service.dart';

class AppState extends ChangeNotifier {
  Utilisateur? _currentUser;
  bool _isOnline = true;
  final AuthService _authService = AuthService();

  Utilisateur? get currentUser => _currentUser;
  bool get isOnline => _isOnline;

  Future<void> initializeApp() async {
    try {
      _currentUser = await _authService.getCurrentUser();
      notifyListeners();
    } catch (e) {
      print('Erreur d\'initialisation: $e');
    }
  }

  void updateOnlineStatus(bool status) {
    _isOnline = status;
    notifyListeners();
  }

  Future<void> updateUserProfile(Map<String, dynamic> userData) async {
    try {
      await _authService.updateProfile(userData);
      _currentUser = await _authService.getCurrentUser();
      notifyListeners();
    } catch (e) {
      print('Erreur de mise à jour du profil: $e');
      rethrow;
    }
  }
}
