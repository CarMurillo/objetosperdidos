import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aplicacion/page/PaginaPrincipal.dart';
import 'package:aplicacion/page/SplashScreen.dart';
import 'package:aplicacion/page/AuthService.dart';

// Configuración de Firebase
const firebaseConfig = FirebaseOptions(
  apiKey: "AIzaSyCm5hq0NtxHXq7NILwkK3UdRveAWPMI-fA",
  appId: "1:60050547136:android:7fb60902b989cda906a825",
  projectId: "proyecto-de-grado-adc82",
  storageBucket: "gs://proyecto-de-grado-adc82.appspot.com",
  messagingSenderId: "your-messaging-sender-id",
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: firebaseConfig);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Mientras se verifica el estado de autenticación, muestra el SplashScreen
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SplashScreen();
          }

          // Si hay un usuario autenticado, muestra la página de inicio
          if (snapshot.hasData) {
            return PaginaPrincipal();
          }

          // Si no hay usuario autenticado, muestra el SplashScreen
          return SplashScreen();
        },
      ),
    );
  }
}