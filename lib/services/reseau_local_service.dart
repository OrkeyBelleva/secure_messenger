import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class ReseauLocalService {
  static const String HOST_PAR_DEFAUT = '192.168.1.1';
  static const int PORT_PAR_DEFAUT = 8080;

  // Configuration Firebase pour le réseau local
  static Future<void> configurerFirebaseLocal() async {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'local',
        appId: 'local',
        messagingSenderId: 'local',
        projectId: 'local',
        // Configuration pour réseau local uniquement
        databaseURL: 'http://$HOST_PAR_DEFAUT:$PORT_PAR_DEFAUT',
      ),
    );

    // Configuration de Firestore pour utilisation locale
    FirebaseFirestore.instance.settings = const Settings(
      host: '$HOST_PAR_DEFAUT:$PORT_PAR_DEFAUT',
      sslEnabled: false,
      persistenceEnabled: true,
    );
  }

  // Vérifier la connectivité au réseau local
  static Future<bool> verifierConnectivite() async {
    try {
      final result = await InternetAddress.lookup(HOST_PAR_DEFAUT);
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  // Obtenir l'adresse IP locale de l'appareil
  static Future<String?> obtenirAdresseIPLocale() async {
    try {
      final interfaces = await NetworkInterface.list(
        includeLoopback: false,
        type: InternetAddressType.IPv4,
      );

      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          if (addr.address.startsWith('192.168.')) {
            return addr.address;
          }
        }
      }
      return null;
    } catch (e) {
      print('Erreur lors de la récupération de l\'adresse IP: $e');
      return null;
    }
  }

  // Vérifier si un hôte est accessible sur le réseau local
  static Future<bool> verifierHoteAccessible(String host) async {
    try {
      final socket = await Socket.connect(host, PORT_PAR_DEFAUT,
          timeout: const Duration(seconds: 2));
      socket.destroy();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Configuration du mode hors ligne
  static Future<void> configurerModeHorsLigne() async {
    await FirebaseFirestore.instance.enablePersistence();
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  // Optimiser la synchronisation des données
  static Future<void> optimiserSynchronisation() async {
    // Réduire la fréquence de synchronisation pour économiser la bande passante
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: 104857600, // 100 MB
    );
  }

  // Gérer la reconnexion automatique
  static Future<void> gererReconnexion(Function callback) async {
    bool connecte = false;
    while (true) {
      try {
        final resultat = await verifierConnectivite();
        if (resultat && !connecte) {
          connecte = true;
          callback();
        } else if (!resultat && connecte) {
          connecte = false;
        }
      } catch (e) {
        print('Erreur de vérification de connexion: $e');
      }
      await Future.delayed(const Duration(seconds: 5));
    }
  }

  // Configurer le cache pour optimisation locale
  static Future<void> configurerCache() async {
    await FirebaseFirestore.instance.clearPersistence();
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: 52428800, // 50 MB
    );
  }

  // Obtenir les statistiques de performance réseau
  static Future<Map<String, dynamic>> obtenirStatistiquesReseau() async {
    try {
      final adresseIP = await obtenirAdresseIPLocale();
      final connecte = await verifierConnectivite();
      
      return {
        'adresseIP': adresseIP,
        'connecte': connecte,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('Erreur lors de la récupération des statistiques: $e');
      return {};
    }
  }
}
