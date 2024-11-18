import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'PaginaPrincipal.dart'; // Asegúrate de tener esta página
import 'perfil.dart'; // Asegúrate de tener esta página

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
    _edificioSeleccionado = 'Edificio A';
  }

  Future<void> _getImageFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    } else {
      print('No se tomó ninguna foto.');
    }
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
      final CollectionReference objetos =
          FirebaseFirestore.instance.collection('objetos');

      await objetos.add({
        'categoria': _categoriaSeleccionada,
        'descripcion': _descripcionController.text,
        'imageUrl': imageUrl,
        'salon': int.tryParse(_salonController.text),
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
          backgroundColor: Color(0xFFC3D631),
          elevation: 0,
          title: Row(
            children: [
              SizedBox(width: 16), // Espacio entre la flecha y el título
              Text(
                'NUEVO OBJETO',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Texto en negro
                ),
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: Color(0xFFE8F5D4), // Fondo blanco crema tirando a verde
            ),
          ),
          Container(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (_imageFile != null)
                      ContenedorPersonalizado(
                        imagePath: _imageFile!.path,
                      ),
                    _buildDropdownField(
                      label: 'Categoría',
                      value: _categoriaSeleccionada,
                      items: ['Objeto Encontrado', 'Objeto Perdido'],
                      onChanged: (value) {
                        setState(() {
                          _categoriaSeleccionada = value!;
                        });
                      },
                    ),
                    SizedBox(height: 16.0),
                    _buildTextField(
                      controller: _descripcionController,
                      label: 'Descripción',
                      validator: (value) => value == null || value.isEmpty
                          ? 'Por favor, ingrese una descripción'
                          : null,
                    ),
                    SizedBox(height: 16.0),
                    _buildTextField(
                      controller: _salonController,
                      label: 'Salón',
                      keyboardType: TextInputType.number,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Por favor, ingrese el número de salón'
                          : int.tryParse(value) == null
                              ? 'El salón debe ser un número entero'
                              : null,
                    ),
                    SizedBox(height: 16.0),
                    _buildDropdownField(
                      label: 'Edificio',
                      value: _edificioSeleccionado,
                      items: ['Edificio A', 'Edificio B', 'Edificio C'],
                      onChanged: (value) {
                        setState(() {
                          _edificioSeleccionado = value!;
                        });
                      },
                    ),
                    SizedBox(height: 16.0),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Color(0xFFC3D631), // Fondo verde
                        foregroundColor: Colors.black, // Texto negro
                        side: BorderSide(color: Color(0xFF002366), width: 2),
                      ),
                      onPressed: _getImageFromGallery,
                      child: Text('Seleccionar Imagen de la Galería'),
                    ),
                    SizedBox(height: 16.0),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Color(0xFFC3D631), // Fondo verde
                        foregroundColor: Colors.black, // Texto negro
                        side: BorderSide(color: Color(0xFF002366), width: 2),
                      ),
                      onPressed: _getImageFromCamera, // Abrir la cámara
                      child: Text('Tomar Foto'),
                    ),
                    SizedBox(height: 16.0),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Color(0xFFC3D631), // Fondo verde
                        foregroundColor: Colors.black, // Texto negro
                        side: BorderSide(color: Color(0xFF002366), width: 2),
                      ),
                      onPressed: () {
                        if (_imageFile != null &&
                            _descripcionController.text.isNotEmpty &&
                            _salonController.text.isNotEmpty) {
                          final Reference ref = FirebaseStorage.instance
                              .ref()
                              .child('${DateTime.now()}.jpg');
                          final UploadTask uploadTask =
                              ref.putFile(_imageFile!);

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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: Colors.black), // Texto en negro
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white, // Fondo blanco
        labelStyle: TextStyle(color: Colors.black),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Color(0xFF002366), width: 3),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Color(0xFF002366), width: 3),
        ),
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item,
            style: TextStyle(color: Colors.black),
          ),
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white, // Fondo blanco
        labelStyle: TextStyle(color: Colors.black), // Texto negro
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Color(0xFF002366), width: 3),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Color(0xFF002366), width: 3),
        ),
      ),
    );
  }
}

class ContenedorPersonalizado extends StatelessWidget {
  final String imagePath;

  const ContenedorPersonalizado({
    Key? key,
    required this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Color(0xFF002366), width: 3),
        borderRadius: BorderRadius.circular(20),
      ),
      width: 300,
      height: 300,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.file(
          File(imagePath),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
