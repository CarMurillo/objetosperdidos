import 'package:flutter/material.dart';
import 'package:aplicacion/page/IniciarSesion.dart';
import 'package:aplicacion/page/Registrarse.dart';
import 'package:url_launcher/url_launcher.dart';

class Inicio extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Color de fondo blanco
      appBar: AppBar(
        title: SizedBox.shrink(), // Eliminar el título
        centerTitle: true,
        backgroundColor: Color(0xFFC3D631), // Color verde
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                height: MediaQuery.of(context).size.width * 0.6,
                child: Image.asset(
                  'img/logo.png',
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 40),
              _buildElevatedButton(
                context,
                'Iniciar sesión',
                () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => IniciarSesion()),
                  );
                },
              ),
              SizedBox(height: 20),
              _buildElevatedButton(
                context,
                'Registrarse',
                () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Registrarse()),
                  );
                },
              ),
              SizedBox(height: 40),
              redessociales(),
            ],
          ),
        ),
      ),
    );
  }

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
