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
  bool _isButtonHovered = false;

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
          backgroundColor: Color(0xFFC3D631),
          elevation: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'OBJETOS PERDIDOS O ENCONTRADOS',
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width *
                      0.045, // Adaptado al ancho de pantalla
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
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
                  width: MediaQuery.of(context).size.width * 0.12,
                  height: MediaQuery.of(context).size.width * 0.12,
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
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.05,
                  color: Colors.black,
                ),
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: objetos.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final imageUrl = data['imageUrl'] as String?;
                final userId = data['userId'] as String? ?? 'unknown_user';
                final descripcion =
                    data['descripcion'] as String? ?? 'Sin descripción';
                final categoria =
                    data['categoria'] as String? ?? 'Sin categoría';
                final salon = data['salon']?.toString() ?? 'Sin salón';
                final edificio = data['edificio'] as String? ?? 'Sin edificio';
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
            backgroundColor: Color(0xFFC3D631),
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'Nuevo Objeto',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: MediaQuery.of(context).size.width *
                      0.035, // Adaptado al ancho de pantalla
                ),
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
    double imageWidth = MediaQuery.of(context).size.width * 0.8;
    double imageHeight = MediaQuery.of(context).size.height * 0.3;

    return Center(
      child: Container(
        margin: EdgeInsets.only(top: 8),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          image: DecorationImage(
            image: AssetImage('img/fondo-app.jpeg'),
            fit: BoxFit.cover,
          ),
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
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Color.fromARGB(255, 65, 105, 225), width: 2),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.transparent,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      category,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.width * 0.04,
                      ),
                    ),
                  ),
                ),
                if (showDeleteIcon)
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: onDelete,
                    iconSize: MediaQuery.of(context).size.width * 0.06,
                  ),
              ],
            ),
            SizedBox(height: 10),
            if (imagePath != null)
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    imagePath!,
                    width: imageWidth,
                    height: imageHeight,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            SizedBox(height: 10),
            Text(
              'Salón: $salon',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: MediaQuery.of(context).size.width * 0.04,
              ),
            ),
            Text(
              '$edificio',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: MediaQuery.of(context).size.width * 0.04,
              ),
            ),
            SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[800]!, width: 1.5),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[300],
              ),
              padding: EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      descriptionText,
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.04,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(iconData, color: Colors.black),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatPage(chatId: chatId),
                        ),
                      );
                    },
                    iconSize: MediaQuery.of(context).size.width * 0.08,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
