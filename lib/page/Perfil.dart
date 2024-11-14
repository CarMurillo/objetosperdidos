import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:aplicacion/page/Inicio.dart';

class Perfil extends StatefulWidget {
  const Perfil({super.key});

  @override
  _PerfilState createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  List<DocumentSnapshot> _objetos = [];

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    _user = _auth.currentUser;
    if (_user != null) {
      final objetosQuery = await _firestore
          .collection('objetos')
          .where('userId', isEqualTo: _user!.uid)
          .get();
      setState(() {
        _objetos = objetosQuery.docs;
      });
    }
  }

  Future<void> _deleteObjeto(String objetoId, String imageUrl) async {
    try {
      await _firestore.collection('objetos').doc(objetoId).delete();
      final ref = FirebaseStorage.instance.refFromURL(imageUrl);
      await ref.delete();
      await _firestore.collection('chats').doc(objetoId).delete();
      _getUserData();
    } catch (e) {
      print('Error al eliminar el objeto: $e');
    }
  }

  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => Inicio()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fondo de pantalla
      body: Stack(
        children: [
          // Imagen de fondo
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      'img/fondo-app.jpeg'), // Cambia la ruta de la imagen si es necesario
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Contenido sobre la imagen de fondo
          Column(
            children: [
              AppBar(
                backgroundColor: Color(0xFFC3D631), // Fondo verde del AppBar
                elevation: 0,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'PERFIL DE USUARIO',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // Texto en blanco para el AppBar
                      ),
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Perfil()),
                        );
                      },
                      child: Image.asset(
                        'img/usuario-verificado.png',
                        width: 50,
                        height: 50,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.logout,
                          color: Colors.white), // Icono en blanco
                      onPressed: _logout,
                    ),
                  ],
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                ),
              ),
              Expanded(
                child: _user == null
                    ? Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Bienvenido, ${_user!.displayName ?? 'Usuario'}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black, // Letras en negro
                              ),
                            ),
                            SizedBox(height: 16.0),
                            Text(
                              'Tus objetos subidos:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black, // Letras en negro
                              ),
                            ),
                            SizedBox(height: 8.0),
                            if (_objetos.isEmpty)
                              Text(
                                'No has subido ningún objeto.',
                                style: TextStyle(
                                    color: Colors.black), // Texto en negro
                              ),
                            for (var objeto in _objetos)
                              Card(
                                color: Colors
                                    .white, // Fondo blanco para los objetos
                                child: ListTile(
                                  leading: Image.network(objeto['imageUrl']),
                                  title: Text(
                                    objeto['descripcion'],
                                    style: TextStyle(
                                        color: Colors
                                            .black), // Texto en negro para los objetos
                                  ),
                                  tileColor: Color(
                                      0xFFC3D631), // Fondo verde de los cuadritos
                                  trailing: IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      _deleteObjeto(
                                          objeto.id, objeto['imageUrl']);
                                    },
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
