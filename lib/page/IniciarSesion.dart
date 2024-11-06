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
      backgroundColor: Colors.white, // Establecer fondo blanco
      appBar: AppBar(
        title: Text('Inicio de Sesión'), // Título de la barra superior
        backgroundColor: Color(0xFFC3D631), // Color de la AppBar
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Center(
            // Centrar todo el contenido
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('img/logo.png', width: 200, height: 300),
                SizedBox(height: 20), // Espacio en blanco

                // Cuadro para el campo de entrada de correo electrónico
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey), // Borde del cuadro
                    borderRadius:
                        BorderRadius.circular(30), // Bordes redondeados
                  ),
                  child: TextField(
                    controller: emailController,
                    style: TextStyle(color: Colors.black), // Texto en negro
                    decoration: InputDecoration(
                      labelText: 'Correo electrónico',
                      labelStyle:
                          TextStyle(color: Colors.black), // Letras en negro
                      border: InputBorder.none, // Sin borde por defecto
                    ),
                  ),
                ),

                SizedBox(height: 16), // Espacio en blanco

                // Cuadro para el campo de entrada de contraseña
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey), // Borde del cuadro
                    borderRadius:
                        BorderRadius.circular(30), // Bordes redondeados
                  ),
                  child: TextField(
                    controller: passwordController,
                    style: TextStyle(color: Colors.black), // Texto en negro
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      labelStyle:
                          TextStyle(color: Colors.black), // Letras en negro
                      border: InputBorder.none, // Sin borde por defecto
                    ),
                    obscureText:
                        true, // Para ocultar el texto en el campo de contraseña
                  ),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(
                        0xFFC3D631), // Color de los botones con referencia #c3d631
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(30), // Bordes redondeados
                    ),
                    padding:
                        EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                  ),
                  child: Text(
                    'Iniciar Sesión',
                    style: TextStyle(color: Colors.black), // Texto en negro
                  ), // Texto del botón de inicio de sesión
                ),

                SizedBox(height: 8), // Espacio en blanco

                // Botón para navegar a la página de registro
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Registrarse()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(
                        0xFFC3D631), // Color de los botones con referencia #c3d631
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(30), // Bordes redondeados
                    ),
                    padding:
                        EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                  ),
                  child: Text(
                    'Registrarse',
                    style: TextStyle(color: Colors.black), // Texto en negro
                  ), // Texto del botón de registro
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
