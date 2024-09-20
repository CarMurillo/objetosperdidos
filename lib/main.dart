import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:aplicacion/page/Inicio.dart';

// Configuración de Firebase
const firebaseConfig = FirebaseOptions(
  apiKey: "AIzaSyA5Kn6KWhdc-SFZfzmZQlGUPvHFcLCz8QU",
  appId: "1:926421817147:android:9c16ef8b390f0c1d2a491e",
  projectId: "cosigocorrecto",
  storageBucket: "gs://cosigocorrecto.appspot.com", //ruta de acceso a storage.
  messagingSenderId: "your-messaging-sender-id",
);

void main() async {
  // Inicializa Firebase con las opciones de configuración
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: firebaseConfig);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData.dark(), // Establece el tema oscuro de la aplicación
      themeMode: ThemeMode.dark, // Configura el modo de tema en oscuro
      home: Inicio(), // Aquí especifica la pantalla de inicio de sesión
    );
  }
}
