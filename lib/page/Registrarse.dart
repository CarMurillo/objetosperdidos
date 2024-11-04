import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aplicacion/page/IniciarSesion.dart';

class Registrarse extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Método para mostrar mensajes emergentes (snackbar) con errores o información
  void showMessage(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // Método para validar la contraseña según las políticas definidas
  bool isValidPassword(String password) {
    if (password.length < 6) return false;
    if (!RegExp(r'[A-Z]').hasMatch(password)) return false; // Mayúscula
    if (!RegExp(r'[a-z]').hasMatch(password)) return false; // Minúscula
    if (!RegExp(r'[0-9]').hasMatch(password)) return false; // Numérico
    if (!RegExp(r'[.,!@#\$&*~]').hasMatch(password)) return false; // Especiales
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Registro'),
        backgroundColor: Color(0xFFC3D631),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'img/logo.png',
                  width: 300.0,
                  height: 300.0,
                ),
                SizedBox(height: 20),

                // Campo de entrada de correo electrónico
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Correo electrónico',
                      border: InputBorder.none,
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),

                SizedBox(height: 16),

                // Campo de entrada de contraseña
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      border: InputBorder.none,
                    ),
                    obscureText: true,
                  ),
                ),

                SizedBox(height: 16),

                // Botón para registrar una nueva cuenta
                ElevatedButton(
                  onPressed: () async {
                    String email = emailController.text.trim();
                    String password = passwordController.text.trim();

                    // Validaciones básicas de email y contraseña
                    if (email.isEmpty) {
                      showMessage(context, 'Por favor, ingrese un correo electrónico.');
                      return;
                    }
                    if (password.isEmpty) {
                      showMessage(context, 'Por favor, ingrese una contraseña.');
                      return;
                    }
                    if (!isValidPassword(password)) {
                      showMessage(context,
                          'La contraseña debe tener al menos 6 caracteres, incluir mayúsculas, minúsculas, números y caracteres especiales.');
                      return;
                    }

                    try {
                      // Intentar registrar una nueva cuenta con Firebase
                      await FirebaseAuth.instance.createUserWithEmailAndPassword(
                        email: email,
                        password: password,
                      );
                      // Registro exitoso, navega a la página de inicio de sesión
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => IniciarSesion()),
                      );
                    } catch (e) {
                      // Error de registro, muestra un mensaje de error
                      showMessage(context, 'Error de registro: ${e.toString()}');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFC3D631),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
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
    );
  }
}
