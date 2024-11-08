import 'package:flutter/material.dart';
import 'package:aplicacion/page/Inicio.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _sizeAnimation;
  late Animation<Offset> _positionAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _navigateToInicio();
  }

  // Inicializa las animaciones
  void _initAnimations() {
    _animationController = AnimationController(
      duration: Duration(seconds: 3), // Duración de la animación
      vsync: this,
    );

    // Animación del tamaño del logo (mucho más grande)
    _sizeAnimation = Tween<double>(begin: 0.5, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    // Animación de la posición (el logo sube un poco)
    _positionAnimation =
        Tween<Offset>(begin: Offset(0, 0), end: Offset(0, -0.1)).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    // Inicia la animación
    _animationController.forward();
  }

  // Navega a la pantalla de inicio después de un tiempo de espera
  Future<void> _navigateToInicio() async {
    await Future.delayed(
        Duration(seconds: 3)); // Tiempo de espera antes de cambiar de pantalla
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Inicio()),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Imagen de fondo
          Container(
            width: double.infinity,
            height: double.infinity,
            child: Image.asset(
              'img/fondo-app.jpeg', // Ruta de la imagen de fondo
              fit: BoxFit.cover,
            ),
          ),
          // Contenido centrado
          Center(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _sizeAnimation.value,
                  child: SlideTransition(
                    position: _positionAnimation,
                    child: child,
                  ),
                );
              },
              child: Image.asset(
                'img/logo.png', // Ruta del logo
                width: MediaQuery.of(context).size.width *
                    1.2, // Tamaño mucho más grande del logo
                height: MediaQuery.of(context).size.width *
                    1.2, // Tamaño mucho más grande del logo
              ),
            ),
          ),
        ],
      ),
    );
  }
}
