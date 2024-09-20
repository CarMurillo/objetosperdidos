// ignore_for_file: unused_import

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aplicacion/page/PaginaPrincipal.dart'; // Importar la página principal
import 'package:aplicacion/page/Registrarse.dart';
//import 'package:shared_preferences/shared_preferences.dart'; //ESTADO DE SESION

class IniciarSesion extends StatelessWidget {
  final TextEditingController emailController =
      TextEditingController(); // Controlador para el campo de correo
  final TextEditingController passwordController =
      TextEditingController(); // Controlador para el campo de contraseña

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inicio de Sesión'), // Título de la barra superior
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset('img/logo.png', width: 200, height: 300),
              // Campo de entrada para el correo electrónico
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                    labelText:
                        'Correo electrónico'), // Etiqueta para el campo de correo
              ),
              // Campo de entrada para la contraseña
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                    labelText:
                        'Contraseña'), // Etiqueta para el campo de contraseña
                obscureText:
                    true, // Para ocultar el texto en el campo de contraseña
              ),
              SizedBox(height: 16), // Espacio en blanco
              // Botón para iniciar sesión
              ElevatedButton(
                onPressed: () async {
                  try {
                    // Intenta iniciar sesión con Firebase
                    await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: emailController.text,
                      password: passwordController.text,
                    );
                    /*
                    // Después de que el usuario inicie sesión correctamente GUARDE EL ESTADO DE SESION
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.setBool('isLoggedIn', true);
                    // Inicio de sesión exitoso, navega a la página principal
                    */
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PaginaPrincipal()),
                    );
                  } catch (e) {
                    // Error de inicio de sesión, muestra un mensaje de error
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Correo electrónico o contraseña incorrectos'), // Mensaje de error en la interfaz
                      ),
                    );
                    print(
                        'Error de inicio de sesión: $e'); // Imprime el error en la consola
                  }
                },
                child: Text(
                    'Iniciar Sesión'), // Texto del botón de inicio de sesión
              ),
              SizedBox(height: 8), // Espacio en blanco
              // Botón para navegar a la página de registro
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Registrarse()),
                  );
                },
                child: Text('Registrarse'), // Texto del botón de registro
              ),
            ],
          ),
        ),
      ),
    );
  }
}
