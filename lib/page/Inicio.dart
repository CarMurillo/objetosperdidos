import 'package:flutter/material.dart';
import 'package:aplicacion/page/IniciarSesion.dart';
import 'package:aplicacion/page/Registrarse.dart';
import 'package:url_launcher/url_launcher.dart';

class Inicio extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Color de fondo blanco
      appBar: null, // Eliminar la AppBar (barra verde superior)
      body: Stack(
        children: [
          // Imagen de fondo
          Container(
            width: double.infinity, // Asegura que ocupe todo el ancho
            height: double.infinity, // Asegura que ocupe todo el alto
            child: Image.asset(
              'img/fondo-app.jpeg', // Ruta de la imagen de fondo
              fit: BoxFit.cover, // La imagen cubre toda la pantalla
            ),
          ),
          // Contenido principal
          Center(
            // Centrar todo el contenido dentro de la pantalla
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Centrado verticalmente
                  crossAxisAlignment:
                      CrossAxisAlignment.center, // Centrado horizontalmente
                  children: [
                    // Espacio para logo, aumento de tamaño
                    SizedBox(
                      width: MediaQuery.of(context).size.width *
                          0.8, // Aumenta el tamaño del logo
                      height: MediaQuery.of(context).size.width *
                          0.8, // Aumenta el tamaño del logo
                      child: Image.asset(
                        'img/logo.png', // Ruta del logo
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: 40),
                    // Botón Iniciar sesión
                    _buildElevatedButton(
                      context,
                      'Iniciar sesión',
                      () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => IniciarSesion()),
                        );
                      },
                    ),
                    SizedBox(height: 20),
                    // Botón Registrarse
                    _buildElevatedButton(
                      context,
                      'Registrarse',
                      () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Registrarse()),
                        );
                      },
                    ),
                    SizedBox(height: 40),
                    // Redes sociales
                    redessociales(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Botón personalizado
  Widget _buildElevatedButton(
      BuildContext context, String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            Color(0xFFC3D631), // Color de los botones con referencia #c3d631
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30), // Bordes redondeados
        ),
        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
        elevation: 5, // Sombra
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 18, color: Colors.black), // Texto en negro
      ),
    );
  }
}

class redessociales extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Nuestras Redes',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black, // Texto en negro
          ),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialIcon(
                'https://www.facebook.com/', 'img/Facebooklogo.jpg'),
            SizedBox(width: 20),
            _buildSocialIcon(
                'https://www.instagram.com/', 'img/logoinstagram.png'),
            SizedBox(width: 20),
            _buildSocialIcon('https://twitter.com/', 'img/logox.png'),
          ],
        ),
      ],
    );
  }

  // Icono de redes sociales
  Widget _buildSocialIcon(String url, String asset) {
    return GestureDetector(
      onTap: () {
        launch(url);
      },
      child: Image.asset(
        asset,
        width: 40,
        height: 40,
      ),
    );
  }
}
