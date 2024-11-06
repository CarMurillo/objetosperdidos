import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aplicacion/page/IniciarSesion.dart';

class Registrarse extends StatelessWidget {
  final TextEditingController emailController =
      TextEditingController(); // Controlador para el campo de correo
  final TextEditingController passwordController =
      TextEditingController(); // Controlador para el campo de contraseña

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Establecer fondo blanco
      appBar: AppBar(
        title: Text('Registro'), // Título de la barra superior
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
                Image.asset(
                  'img/logo.png',
                  width: 300.0,
                  height: 300.0,
                ),
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

                // Botón para registrar una nueva cuenta
                ElevatedButton(
                  onPressed: () async {
                    try {
                      // Intenta registrar una nueva cuenta con Firebase
                      await FirebaseAuth.instance
                          .createUserWithEmailAndPassword(
                        email: emailController.text,
                        password: passwordController.text,
                      );
                      // Registro exitoso, navega a la página de inicio de sesión
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => IniciarSesion()),
                      );
                    } catch (e) {
                      // Error de registro, muestra un mensaje de error
                      print(
                          'Error de registro: $e'); // Imprime el error en la consola
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
                    'Registrarse', // Texto del botón de registro
                    style: TextStyle(color: Colors.black), // Texto en negro
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
