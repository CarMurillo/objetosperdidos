import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:aplicacion/page/Inicio.dart';

// Configuración de Firebase
const firebaseConfig = FirebaseOptions(
  apiKey: "AIzaSyCm5hq0NtxHXq7NILwkK3UdRveAWPMI-fA",
  appId: "1:60050547136:android:7fb60902b989cda906a825",
  projectId: "proyecto-de-grado-adc82",
  storageBucket: "gs://proyecto-de-grado-adc82.appspot.com", //ruta de acceso a storage.
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
