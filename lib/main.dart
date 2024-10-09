import 'package:flutter/material.dart';
import 'cadastro.dart';
import 'chatbot.dart';
import 'login_screen.dart';
import 'homepage_screen.dart';
import 'agenda_screen.dart';
import 'clientes_screen.dart';
import 'processos_screen.dart';

void main() {
  runApp(MyLexApp());
}

class MyLexApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyLex App',
      theme: ThemeData(
        primaryColor: Colors.black, // Define a cor primária para o app
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black, // Define a cor de fundo do AppBar
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20), // Cor e estilo do texto no AppBar
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            primary: Colors.black, // Cor de fundo do ElevatedButton
            onPrimary: Colors.white, // Cor do texto do botão
          ),
        ),
      ),
      initialRoute: '/login', // Rota inicial
      routes: {
        '/login': (context) => LoginScreen(),
        '/homepage': (context) => HomePageScreen(),
        '/agenda': (context) => AgendaScreen(),
        '/clientes': (context) => ClientesScreen(),
        '/processos': (context) => ProcessosScreen(),
        '/cadastro': (context) => CadastroScreen(),
        '/chatbot': (context) => ChatbotScreen(),
      },
    );
  }
}
