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
          backgroundColor: Color(0xFFC3D631), // Color de la AppBar
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
      body: Stack(
        children: [
          // Fondo de pantalla
          Center(
            child: Container(
              width: 300, // Ajusta el ancho deseado
              height: 300, // Ajusta la altura deseada
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      'img/fondo-universidad.png'), // Ruta de tu imagen de fondo
                  fit: BoxFit
                      .cover, // Asegúrate de que la imagen cubra el contenedor
                ),
              ),
            ),
          ),
          // Contenedor con contenido
          Container(
            color: Colors.white, // Fondo blanco
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
                        foregroundColor: Colors.black,
                        side: BorderSide(color: Color(0xFF002366), width: 2),
                      ),
                      onPressed: _getImageFromGallery,
                      child: Text('Seleccionar Imagen'),
                    ),
                    SizedBox(height: 16.0),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
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
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
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
            style: TextStyle(color: Colors.white), // Cambiar a texto blanco
          ),
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Color(0xFF002366), // Fondo del desplegable
        labelStyle: TextStyle(color: Colors.white), // Etiqueta en blanco
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

  const ContenedorPersonalizado({Key? key, required this.imagePath})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFF002366), width: 2),
        borderRadius: BorderRadius.circular(10),
        image: DecorationImage(
          image: FileImage(File(imagePath)),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
