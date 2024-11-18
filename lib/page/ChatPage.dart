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
          backgroundColor: Color(0xFFC3D631),
          elevation: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CHAT',
                style: TextStyle(
                  fontSize: 18,
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
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.height * 0.3,
                      child: Image.asset(
                        'img/imagen-universidad.jpg',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  StreamBuilder(
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
                        return Center(
                          child: Text(
                            'No hay mensajes aún. Sé el primero en enviar uno!',
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        );
                      }

                      List<Widget> messageWidgets = [];
                      for (var message in messages) {
                        final messageText = message['text'];
                        final messageSender = message['sender'];
                        final messageId = message.id;

                        final currentUser = _auth.currentUser;
                        final messageWidget = MessageBubble(
                          text: messageText,
                          sender: messageSender,
                          isMe: currentUser != null &&
                              currentUser.email == messageSender,
                          messageId: messageId,
                          chatId: widget.chatId,
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
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: TextStyle(
                          color: Colors.black), // Color negro para el texto
                      decoration: InputDecoration(
                        hintText: 'Escribe tu mensaje...',
                        hintStyle: TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: Colors.white, // Fondo blanco
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
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
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String text;
  final String sender;
  final bool isMe;
  final String messageId;
  final String chatId;

  const MessageBubble({
    required this.text,
    required this.sender,
    required this.isMe,
    required this.messageId,
    required this.chatId,
  });

  void _deleteMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white, // Fondo blanco
          title: Text(
            "Eliminar mensaje",
            style: TextStyle(color: Colors.black), // Texto en negro
          ),
          content: Text(
            "¿Estás seguro de que quieres eliminar este mensaje?",
            style: TextStyle(color: Colors.black), // Texto en negro
          ),
          actions: [
            TextButton(
              child: Text("Cancelar", style: TextStyle(color: Colors.black)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Eliminar", style: TextStyle(color: Colors.red)),
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance
                      .collection('chats')
                      .doc(chatId)
                      .collection('messages')
                      .doc(messageId)
                      .delete();
                  Navigator.of(context).pop();
                } catch (e) {
                  print('Error al eliminar el mensaje: $e');
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        if (isMe) {
          _deleteMessage(context);
        }
      },
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              sender,
              style: TextStyle(
                fontSize: 12,
                color: Colors.black,
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
                  ? Color.fromARGB(255, 144, 238, 144)
                  : Color.fromARGB(255, 224, 255, 255),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Text(
                  text,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
