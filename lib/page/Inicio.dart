import 'package:flutter/material.dart';
import 'package:aplicacion/page/IniciarSesion.dart';
import 'package:aplicacion/page/Registrarse.dart';
import 'package:url_launcher/url_launcher.dart';

class Inicio extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('INICIO'), // Título de la barra superior
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
              ElevatedButton(
                onPressed: () async {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => IniciarSesion()),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 32.0),
                  child: Text(
                    'Iniciar sesión', // Texto del botón de Inicio de sesión
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Registrarse()),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 32.0),
                  child: Text(
                    'Registrarse', // Texto del botón de Registrarse
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              SizedBox(height: 40),
              redessociales(),
            ],
          ),
        ),
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
          ),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                launch('https://www.facebook.com/');
              },
              child: Image.asset(
                'img/Facebooklogo.jpg',
                width: 40,
                height: 40,
              ),
            ),
            SizedBox(width: 20),
            GestureDetector(
              onTap: () {
                launch('https://www.instagram.com/');
              },
              child: Image.asset(
                'img/logoinstagram.png',
                width: 40,
                height: 40,
              ),
            ),
            SizedBox(width: 20),
            GestureDetector(
              onTap: () {
                launch('https://twitter.com/');
              },
              child: Image.asset(
                'img/logox.png',
                width: 40,
                height: 40,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
