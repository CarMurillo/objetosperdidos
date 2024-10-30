import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:aplicacion/page/PaginaPrincipal.dart';
import 'package:aplicacion/page/Perfil.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ObjetoEncontrado extends StatefulWidget {
  @override
  _ObjetoEncontradoState createState() => _ObjetoEncontradoState();
}

class _ObjetoEncontradoState extends State<ObjetoEncontrado> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  List<String> imageUrls = [];
  late TextEditingController _descripcionController;
  late TextEditingController _salonController;
  late String _categoriaSeleccionada;
  late String _edificioSeleccionado;

  @override
  void initState() {
    super.initState();
    _descripcionController = TextEditingController();
    _salonController = TextEditingController();
    _categoriaSeleccionada = 'Objeto Encontrado';
    _edificioSeleccionado = 'Edificio A'; // Valor inicial para el Dropdown
  }

  Future<void> _getImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    } else {
      print('No se seleccionó ninguna imagen.');
    }
  }

  Future<void> guardarDatosEnFirestore(String imageUrl) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final CollectionReference objetos = FirebaseFirestore.instance.collection('objetos');

      await objetos.add({
        'categoria': _categoriaSeleccionada,
        'descripcion': _descripcionController.text,
        'imageUrl': imageUrl,
        'salon': int.tryParse(_salonController.text), // Guardar el salón como número entero
        'edificio': _edificioSeleccionado,
        'userId': user.uid,
        'userEmail': user.email,
        'timestamp': FieldValue.serverTimestamp(),
      });

      Navigator.pop(
        context,
        MaterialPageRoute(builder: (context) => PaginaPrincipal()),
      );
    } else {
      print('Usuario no autenticado');
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_imageFile != null)
              ContenedorPersonalizado(
                imagePath: _imageFile!.path,
              ),
            DropdownButtonFormField<String>(
              value: _categoriaSeleccionada,
              onChanged: (value) {
                setState(() {
                  _categoriaSeleccionada = value!;
                });
              },
              items: ['Objeto Encontrado', 'Objeto Perdido'].map((categoria) {
                return DropdownMenuItem<String>(
                  value: categoria,
                  child: Text(categoria),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Categoría',
              ),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _descripcionController,
              decoration: InputDecoration(
                labelText: 'Descripción',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, ingrese una descripción';
                }
                return null;
              },
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _salonController,
              decoration: InputDecoration(
                labelText: 'Salón',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, ingrese el número de salón';
                }
                if (int.tryParse(value) == null) {
                  return 'El salón debe ser un número entero';
                }
                return null;
              },
            ),
            SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              value: _edificioSeleccionado,
              onChanged: (value) {
                setState(() {
                  _edificioSeleccionado = value!;
                });
              },
              items: ['Edificio A', 'Edificio B', 'Edificio C'].map((edificio) {
                return DropdownMenuItem<String>(
                  value: edificio,
                  child: Text(edificio),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Edificio',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _getImageFromGallery,
              child: Text('Seleccionar Imagen'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                if (_imageFile != null &&
                    _descripcionController.text.isNotEmpty &&
                    _salonController.text.isNotEmpty) {
                  final Reference ref = FirebaseStorage.instance
                      .ref()
                      .child('${DateTime.now()}.jpg');
                  final UploadTask uploadTask = ref.putFile(_imageFile!);

                  uploadTask.whenComplete(() async {
                    final url = await ref.getDownloadURL();
                    setState(() {
                      imageUrls.add(url);
                    });

                    guardarDatosEnFirestore(url);
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Por favor, seleccione una imagen, agregue una descripción y el salón.'),
                    ),
                  );
                }
              },
              child: Text('Subir Objeto'),
            ),
          ],
        ),
      ),
    );
  }
}

class ContenedorPersonalizado extends StatelessWidget {
  final String imagePath;

  const ContenedorPersonalizado({
    required this.imagePath,
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
            SizedBox(height: 0.3),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(
                File(imagePath),
                width: 300,
                height: 300,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
