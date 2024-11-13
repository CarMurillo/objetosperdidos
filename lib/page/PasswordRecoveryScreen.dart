import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PasswordRecoveryScreen extends StatefulWidget {
  @override
  _PasswordRecoveryScreenState createState() => _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState extends State<PasswordRecoveryScreen> {
  final _emailController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  Future<void> _sendPasswordResetEmail() async {
    if (_emailController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Por favor ingresa un correo electrónico';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      // Primero verificamos si el correo existe
      var methods = await _auth.fetchSignInMethodsForEmail(_emailController.text.trim());
      
      if (methods.isEmpty) {
        setState(() {
          _errorMessage = 'El correo electrónico no está registrado';
          _isLoading = false;
        });
        return;
      }

      // Si el correo existe, enviamos el email de recuperación
      await _auth.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      setState(() {
        _successMessage = 'Se ha enviado un correo de recuperación';
        _emailController.clear();
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        switch (e.code) {
          case 'invalid-email':
            _errorMessage = 'El correo electrónico no es válido';
            break;
          case 'user-not-found':
            _errorMessage = 'El correo electrónico no está registrado';
            break;
          default:
            _errorMessage = 'Ocurrió un error al enviar el correo';
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Ocurrió un error inesperado';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Recuperar Contraseña',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Color(0xFFC3D631),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            child: Image.asset(
              'img/fondo-app.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.white.withOpacity(0.8),
                  ),
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Correo Electrónico',
                      labelStyle: TextStyle(color: Colors.black),
                      hintText: 'Ingresa tu correo electrónico',
                      border: InputBorder.none,
                    ),
                    style: TextStyle(color: Colors.black),
                    keyboardType: TextInputType.emailAddress,
                    enabled: !_isLoading,
                  ),
                ),
                SizedBox(height: 16),
                if (_errorMessage != null)
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (_successMessage != null)
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _successMessage!,
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _sendPasswordResetEmail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFC3D631),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Enviar correo de recuperación',
                            style: TextStyle(color: Colors.black),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}