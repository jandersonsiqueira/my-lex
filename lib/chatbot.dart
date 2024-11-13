import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatbotScreen extends StatefulWidget {
  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Message> messages = [];

  Future<void> sendMessage(String message) async {
    if (message.isEmpty) return;

    setState(() {
      messages.add(Message(message: message, isUser: true));
    });

    final response = await http.post(
      Uri.parse('https://api-gemini-9uiw.onrender.com/chat'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'pergunta': message}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      String botResponse = data['resposta'];

      _controller.clear();

      setState(() {
        messages.add(Message(message: botResponse, isUser: false));
      });
    } else {
      setState(() {
        messages.add(Message(message: 'Erro ao obter resposta do bot.', isUser: false));
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chatbot'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/homepage');
          },
        ),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(messages[index]);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    bool isUser = message.isUser;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) _buildAvatar(isUser: false), // Bot avatar
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12.0),
              margin: EdgeInsets.symmetric(horizontal: 8.0),
              decoration: BoxDecoration(
                color: isUser ? Colors.black : Colors.grey[300],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: isUser ? Radius.circular(16) : Radius.circular(0),
                  bottomRight: isUser ? Radius.circular(0) : Radius.circular(16),
                ),
              ),
              child: Text(
                message.message,
                style: TextStyle(color: isUser ? Colors.white : Colors.black87),
              ),
            ),
          ),
          if (isUser) _buildAvatar(isUser: true), // User avatar
        ],
      ),
    );
  }

  Widget _buildAvatar({required bool isUser}) {
    return CircleAvatar(
      radius: 18,
      backgroundColor: isUser ? Colors.black : Colors.grey[300],
      child: Icon(
        isUser ? Icons.person : Icons.android,
        color: isUser ? Colors.white : Colors.black54,
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Digite sua pergunta...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              ),
            ),
          ),
          SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.black,
            child: IconButton(
              icon: Icon(Icons.send, color: Colors.white),
              onPressed: () {
                sendMessage(_controller.text);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Message {
  final String message;
  final bool isUser;

  Message({required this.message, required this.isUser});
}
