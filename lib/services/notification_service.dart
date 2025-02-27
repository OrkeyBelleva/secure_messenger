import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Initialiser les notifications
  Future<void> initialiser() async {
    // Demander la permission pour les notifications
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Configurer les notifications locales
    const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await _localNotifications.initialize(initializationSettings);

    // Configurer les canaux de notification pour Android
    const channelMessage = AndroidNotificationChannel(
      'messages_channel',
      'Messages',
      description: 'Notifications pour les nouveaux messages',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    const channelDocument = AndroidNotificationChannel(
      'documents_channel',
      'Documents',
      description: 'Notifications pour les validations de documents',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannels([channelMessage, channelDocument]);

    // Gérer les notifications en arrière-plan
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

    // Gérer les notifications en premier plan
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Gérer le clic sur les notifications
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationClick);
  }

  // Enregistrer le token FCM pour un utilisateur
  Future<void> enregistrerToken(String userId) async {
    final token = await _fcm.getToken();
    if (token != null) {
      await _db.collection('tokens').doc(userId).set({
        'token': token,
        'derniereMiseAJour': FieldValue.serverTimestamp(),
      });
    }
  }

  // Envoyer une notification pour un nouveau message
  Future<void> envoyerNotificationMessage({
    required String destinataireId,
    required String expediteurNom,
    required String message,
    String? groupeNom,
  }) async {
    final token = await _getTokenUtilisateur(destinataireId);
    if (token == null) return;

    final notification = {
      'notification': {
        'title': groupeNom ?? expediteurNom,
        'body': message,
        'sound': 'default',
      },
      'data': {
        'type': 'message',
        'expediteurNom': expediteurNom,
        'groupeNom': groupeNom,
      },
      'to': token,
    };

    await _envoyerNotificationFCM(notification);
  }

  // Envoyer une notification pour la validation d'un document
  Future<void> envoyerNotificationDocument({
    required String destinataireId,
    required String nomDocument,
    required bool estValide,
  }) async {
    final token = await _getTokenUtilisateur(destinataireId);
    if (token == null) return;

    final status = estValide ? 'validé' : 'refusé';
    final notification = {
      'notification': {
        'title': 'Validation de document',
        'body': 'Votre document "$nomDocument" a été $status',
        'sound': 'default',
      },
      'data': {
        'type': 'document',
        'documentNom': nomDocument,
        'status': status,
      },
      'to': token,
    };

    await _envoyerNotificationFCM(notification);
  }

  // Obtenir le token FCM d'un utilisateur
  Future<String?> _getTokenUtilisateur(String userId) async {
    final doc = await _db.collection('tokens').doc(userId).get();
    return doc.data()?['token'] as String?;
  }

  // Envoyer une notification via FCM
  Future<void> _envoyerNotificationFCM(Map<String, dynamic> notification) async {
    const url = 'https://fcm.googleapis.com/fcm/send';
    // Note: Dans une vraie application, cette partie serait gérée par le backend
    // pour des raisons de sécurité (la clé API ne doit pas être exposée côté client)
  }

  // Gérer les messages en arrière-plan
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    print('Message reçu en arrière-plan: ${message.messageId}');
  }

  // Gérer les messages en premier plan
  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    final android = message.notification?.android;
    
    if (notification != null && android != null) {
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'messages_channel',
            'Messages',
            icon: android.smallIcon,
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
    }
  }

  // Gérer le clic sur une notification
  void _handleNotificationClick(RemoteMessage message) {
    // TODO: Implémenter la navigation vers l'écran approprié
    print('Notification cliquée: ${message.messageId}');
  }

  // Désactiver les notifications pour un utilisateur
  Future<void> desactiverNotifications(String userId) async {
    await _db.collection('tokens').doc(userId).delete();
  }

  // Mettre à jour les préférences de notification
  Future<void> mettreAJourPreferences(String userId, {
    required bool nouveauxMessages,
    required bool validationDocuments,
    required bool nouveauxMembres,
  }) async {
    await _db.collection('preferences_notifications').doc(userId).set({
      'nouveauxMessages': nouveauxMessages,
      'validationDocuments': validationDocuments,
      'nouveauxMembres': nouveauxMembres,
      'derniereMiseAJour': FieldValue.serverTimestamp(),
    });
  }
}
