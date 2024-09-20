import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
      // Eliminar el objeto de Firestore
      await _firestore.collection('objetos').doc(objetoId).delete();

      // Eliminar la imagen de Firebase Storage
      final ref = FirebaseStorage.instance.refFromURL(imageUrl);
      await ref.delete();

      // Eliminar el chat asociado (suponiendo que el chat tiene el mismo ID que el objeto)
      await _firestore.collection('chats').doc(objetoId).delete();

      _getUserData(); // Refresh the list after deletion
    } catch (e) {
      print('Error al eliminar el objeto: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: AppBar(
          backgroundColor: Color.fromARGB(255, 105, 208, 240),
          elevation: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'OBJETOS PERDIDOS',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
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
              )
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),
        ),
      ),
      body: _user == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bienvenido, ${_user!.displayName ?? 'Usuario'}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Tus objetos subidos:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.0),
                  if (_objetos.isEmpty) Text('No has subido ningún objeto.'),
                  for (var objeto in _objetos)
                    Card(
                      child: ListTile(
                        leading: Image.network(objeto['imageUrl']),
                        title: Text(objeto['descripcion']),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _deleteObjeto(objeto.id, objeto['imageUrl']);
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
