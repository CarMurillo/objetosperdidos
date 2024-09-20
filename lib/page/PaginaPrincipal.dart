import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:aplicacion/page/ObjetoEncontrado.dart';
import 'package:aplicacion/page/Perfil.dart';
import 'package:aplicacion/page/ChatPage.dart';

class PaginaPrincipal extends StatefulWidget {
  @override
  _PaginaPrincipalState createState() => _PaginaPrincipalState();
}

class _PaginaPrincipalState extends State<PaginaPrincipal> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
  }

  Future<void> _deleteObject(String docId, String imageUrl) async {
    try {
      // Eliminar la imagen de Firebase Storage
      await FirebaseStorage.instance.refFromURL(imageUrl).delete();

      // Eliminar el documento de Firestore
      await FirebaseFirestore.instance
          .collection('objetos')
          .doc(docId)
          .delete();
    } catch (e) {
      print('Error eliminando el objeto: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: AppBar(
          backgroundColor: Color.fromARGB(255, 65, 131, 151),
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('objetos').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final objetos = snapshot.data!.docs;

          return SingleChildScrollView(
            child: Column(
              children: objetos.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final imageUrl = data['imageUrl'] as String;
                final userId = data['userId'] as String;
                final descripcion = data['descripcion'] as String;
                final categoria = data['categoria'] as String;
                final chatId = doc.id; // Usar el ID del documento como chatId

                return ContenedorPersonalizado(
                  imagePath: imageUrl,
                  category: categoria,
                  descriptionText: descripcion,
                  iconData: Icons.message_rounded,
                  showDeleteIcon:
                      _currentUser != null && _currentUser!.uid == userId,
                  onDelete: () => _deleteObject(doc.id, imageUrl),
                  chatId: chatId,
                );
              }).toList(),
            ),
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Align(
          alignment: Alignment.bottomRight,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ObjetoEncontrado()),
              );
            },
            backgroundColor: Color.fromARGB(255, 86, 90, 139),
            child: Text('Nuevo'),
          ),
        ),
      ),
    );
  }
}

class ContenedorPersonalizado extends StatelessWidget {
  final String imagePath;
  final String category;
  final String descriptionText;
  final IconData iconData;
  final bool showDeleteIcon;
  final VoidCallback onDelete;
  final String chatId; // Agregado para recibir el ID del chat

  const ContenedorPersonalizado({
    required this.imagePath,
    required this.category,
    required this.descriptionText,
    required this.iconData,
    this.showDeleteIcon = false,
    required this.onDelete,
    required this.chatId, // Agregado para recibir el ID del chat
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.only(top: 8),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color.fromARGB(255, 74, 102, 126),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 5)
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    // Acción del botón (opcional)
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Color.fromARGB(255, 105, 188, 163),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Text(
                      category,
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                if (showDeleteIcon)
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: onDelete,
                  ),
              ],
            ),
            SizedBox(height: 0.3),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                imagePath,
                width: 300,
                height: 300,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 20),
            Container(
              color: Color.fromARGB(68, 255, 255, 255),
              padding: EdgeInsets.all(4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      descriptionText,
                    ),
                  ),
                  SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ChatPage(chatId: chatId), // Pasar el ID del chat
                        ),
                      );
                    },
                    child: Icon(
                      iconData,
                      size: 40,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
