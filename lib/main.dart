import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/reseau_local_service.dart';
import 'services/auth_service.dart';
import 'services/encryption_service.dart';
import 'providers/app_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation des services
  final encryptionService = EncryptionService();
  await encryptionService.initialize();

  // Configuration pour le réseau local
  await ReseauLocalService.configurerFirebaseLocal();
  await ReseauLocalService.configurerCache();

  // Démarrer la surveillance du réseau
  ReseauLocalService.gererReconnexion(() {
    print('Reconnecté au réseau local');
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: const MonApplication(),
    ),
  );
}

class MonApplication extends StatelessWidget {
  const MonApplication({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Messagerie Sécurisée',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const PageConnexion(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PageConnexion extends StatefulWidget {
  const PageConnexion({super.key});

  @override
  State<PageConnexion> createState() => _PageConnexionState();
}

class _PageConnexionState extends State<PageConnexion> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connexion'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Mot de passe',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre mot de passe';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      final user = await _authService.connexionEmail(
                        _emailController.text,
                        _passwordController.text,
                      );
                      if (user != null) {
                        if (!mounted) return;
                        context.read<AppState>().initializeApp();
                        // TODO: Naviguer vers la page d'accueil ou tableau de bord
                      }
                    } catch (e) {
                      if (!mounted) return;
                      ErrorHandler.handleError(context, e,
                          customMessage: 'Erreur de connexion');
                    }
                  }
                },
                child: const Text('Se connecter'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
