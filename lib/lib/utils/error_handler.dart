import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class ErrorHandler {
  static final Logger _logger = Logger();

  static void handleError(BuildContext context, dynamic error,
      {String? customMessage}) {
    _logger.e('Erreur: $error');

    String message = customMessage ?? 'Une erreur est survenue';
    if (error is FirebaseException) {
      message = _getFirebaseErrorMessage(error);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
          textColor: Colors.white,
        ),
      ),
    );
  }

  static String _getFirebaseErrorMessage(FirebaseException error) {
    switch (error.code) {
      case 'network-request-failed':
        return 'Erreur de connexion réseau';
      case 'permission-denied':
        return 'Accès non autorisé';
      default:
        return error.message ?? 'Erreur Firebase inconnue';
    }
  }
}
