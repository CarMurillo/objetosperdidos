import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aplicacion/page/IniciarSesion.dart';
import 'package:aplicacion/page/Inicio.dart';

class Registrarse extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Colors.black), // Cambiar color de la flecha a negro
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      Inicio()), // Cambiar a la pantalla de inicio
            );
          },
        ),
        title: Text(
          'Registro',
          style: TextStyle(
              color: Colors.black), // Cambiar color del título a negro
        ),
        backgroundColor: Color(0xFFC3D631),
      ),
      body: Stack(
        children: [
          // Imagen de fondo
          Container(
            width: double.infinity,
            height: double.infinity,
            child: Image.asset(
              'img/fondo-app.jpeg', // Ruta de la imagen de fondo
              fit: BoxFit.cover, // La imagen cubre toda la pantalla
            ),
          ),
          // Contenido principal
          Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Centrado verticalmente
                  crossAxisAlignment:
                      CrossAxisAlignment.center, // Centrado horizontalmente
                  children: [
                    // Logo
                    SizedBox(
                      width: MediaQuery.of(context).size.width *
                          0.8, // Aumento el tamaño del logo
                      height: MediaQuery.of(context).size.width *
                          0.8, // Aumento el tamaño del logo
                      child: Image.asset(
                        'img/logo.png', // Ruta del logo
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: 20),
                    // Campo de correo electrónico
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black), // Borde negro
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextField(
                        controller: emailController,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          labelText: 'Correo electrónico',
                          labelStyle: TextStyle(color: Colors.black),
                          border: InputBorder
                              .none, // Para evitar el borde predeterminado
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    // Campo de contraseña
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black), // Borde negro
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextField(
                        controller: passwordController,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          labelStyle: TextStyle(color: Colors.black),
                          border: InputBorder
                              .none, // Para evitar el borde predeterminado
                        ),
                        obscureText: true,
                      ),
                    ),
                    SizedBox(height: 16),
                    // Botón Registrarse
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          await FirebaseAuth.instance
                              .createUserWithEmailAndPassword(
                            email: emailController.text,
                            password: passwordController.text,
                          );
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => IniciarSesion()),
                          );
                        } catch (e) {
                          print('Error de registro: $e');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFC3D631),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 32.0),
                      ),
                      child: Text(
                        'Registrarse',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
