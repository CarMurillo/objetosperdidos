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
      await FirebaseStorage.instance.refFromURL(imageUrl).delete();
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
          backgroundColor: Color(0xFFC3D631), // Verde claro
          elevation: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'OBJETOS PERDIDOS',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Texto en blanco
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

          if (objetos.isEmpty) {
            return Center(
              child: Text(
                'No hay ningún objeto subido',
                style:
                    TextStyle(fontSize: 18, color: Colors.black), // Texto negro
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: objetos.map((doc) {
                final data = doc.data() as Map<String, dynamic>;

                final imageUrl = data['imageUrl'] != null
                    ? data['imageUrl'] as String
                    : null;
                final userId = data['userId'] != null
                    ? data['userId'] as String
                    : 'unknown_user';
                final descripcion = data['descripcion'] != null
                    ? data['descripcion'] as String
                    : 'Sin descripción';
                final categoria = data['categoria'] != null
                    ? data['categoria'] as String
                    : 'Sin categoría';
                final salon = data['salon'] != null
                    ? data['salon'].toString()
                    : 'Sin salón';
                final edificio = data['edificio'] != null
                    ? data['edificio'] as String
                    : 'Sin edificio';
                final chatId = doc.id;

                return ContenedorPersonalizado(
                  imagePath: imageUrl,
                  category: categoria,
                  descriptionText: descripcion,
                  salon: salon,
                  edificio: edificio,
                  iconData: Icons.message_rounded,
                  showDeleteIcon:
                      _currentUser != null && _currentUser!.uid == userId,
                  onDelete: () => _deleteObject(doc.id, imageUrl ?? ''),
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
            backgroundColor: Color(0xFFC3D631), // Verde claro
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'Nuevo Objeto',
                style: TextStyle(color: Colors.white), // Texto en blanco
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ContenedorPersonalizado extends StatelessWidget {
  final String? imagePath;
  final String category;
  final String descriptionText;
  final String salon;
  final String edificio;
  final IconData iconData;
  final bool showDeleteIcon;
  final VoidCallback onDelete;
  final String chatId;

  const ContenedorPersonalizado({
    required this.imagePath,
    required this.category,
    required this.descriptionText,
    required this.salon,
    required this.edificio,
    required this.iconData,
    this.showDeleteIcon = false,
    required this.onDelete,
    required this.chatId,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.only(top: 8),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.blue[50], // Fondo azul celeste muy claro
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5)
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Contenedor con borde azul rey y fondo transparente
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Color.fromARGB(255, 65, 105, 225),
                        width: 3), // Borde azul rey más grueso
                    borderRadius:
                        BorderRadius.circular(8), // Redondear los bordes
                    color: Colors.transparent, // Fondo transparente
                  ),
                  padding: EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2), // Más ajustado
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      category,
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold), // Texto en negro
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
            SizedBox(height: 10),
            if (imagePath != null)
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Colors.black,
                      width: 2), // Borde negro alrededor de la imagen
                  borderRadius: BorderRadius.circular(10), // Bordes redondeados
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    imagePath!,
                    width: 300,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            SizedBox(height: 10),
            Text('Salón: $salon',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black)), // Texto negro
            Text('Edificio: $edificio',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black)), // Texto negro
            SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                    color: Colors.grey[800]!, width: 1.5), // Borde gris oscuro
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[300], // Color gris claro para el fondo
              ),
              padding: EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      descriptionText,
                      style: TextStyle(
                          fontSize: 14, color: Colors.black), // Texto negro
                    ),
                  ),
                  SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatPage(chatId: chatId),
                        ),
                      );
                    },
                    child: Icon(
                      iconData,
                      size: 40,
                      color: Colors.grey[800], // Gris oscuro para el icono
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
