import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aplicacion/page/Perfil.dart';

class ChatPage extends StatefulWidget {
  final String chatId;

  ChatPage({required this.chatId});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: AppBar(
          backgroundColor: Color.fromARGB(255, 90, 245, 90), // Verde claro
          elevation: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CHAT',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Color negro
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
      body: Container(
        color: Colors.white, // Fondo blanco
        child: Stack(
          children: [
            // Imagen de fondo
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width *
                    0.8, // 80% del ancho de la pantalla
                height: MediaQuery.of(context).size.height *
                    0.3, // 30% de la altura de la pantalla
                child: Image.asset(
                  'img/imagen-universidad.jpg',
                  fit: BoxFit.contain, // Ajusta la imagen sin recortarla
                ),
              ),
            ),
            // Contenido del chat
            Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                    stream: _firestore
                        .collection('chats')
                        .doc(widget.chatId)
                        .collection('messages')
                        .orderBy('timestamp')
                        .snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (!snapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      final messages = snapshot.data!.docs.reversed;

                      if (messages.isEmpty) {
                        // Si no hay mensajes, mostramos el mensaje
                        return Center(
                          child: Text(
                            'No hay mensajes aún. Sé el primero en enviar uno!',
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.black), // Color negro
                          ),
                        );
                      }

                      List<Widget> messageWidgets = [];
                      for (var message in messages) {
                        final messageText = message['text'];
                        final messageSender = message['sender'];

                        final currentUser = _auth.currentUser;
                        final messageWidget = MessageBubble(
                          text: messageText,
                          sender: messageSender,
                          isMe: currentUser != null &&
                              currentUser.email == messageSender,
                        );
                        messageWidgets.add(messageWidget);
                      }
                      return ListView(
                        reverse: true,
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                        children: messageWidgets,
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: 'Type your message...',
                            hintStyle: TextStyle(
                                color: Colors
                                    .grey), // Puedes cambiar el color del texto del hint si lo deseas
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.send, color: Colors.green),
                        onPressed: () async {
                          final currentUser = _auth.currentUser;
                          if (currentUser != null) {
                            await _firestore
                                .collection('chats')
                                .doc(widget.chatId)
                                .collection('messages')
                                .add({
                              'text': _messageController.text,
                              'sender': currentUser.email,
                              'timestamp': FieldValue.serverTimestamp(),
                            });
                            _messageController.clear();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String text;
  final String sender;
  final bool isMe;

  const MessageBubble({
    required this.text,
    required this.sender,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            sender,
            style: TextStyle(
              fontSize: 12,
              color: Colors.black, // Color negro
            ),
          ),
          Material(
            borderRadius: BorderRadius.only(
              topLeft: isMe ? Radius.circular(30) : Radius.circular(0),
              topRight: isMe ? Radius.circular(0) : Radius.circular(30),
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            elevation: 5,
            color: isMe
                ? Color.fromARGB(
                    255, 144, 238, 144) // Verde claro para los mensajes propios
                : Color.fromARGB(255, 224, 255,
                    255), // Celeste claro para mensajes recibidos
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Text(
                text,
                style: TextStyle(
                  color: Colors.black, // Texto negro en ambos tipos de mensajes
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
