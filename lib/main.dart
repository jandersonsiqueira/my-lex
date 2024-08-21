import 'package:flutter/material.dart';
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
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login', // Rota inicial
      routes: {
        '/login': (context) => LoginScreen(),
        '/homepage': (context) => HomePageScreen(),
        '/agenda': (context) => AgendaScreen(),
        '/clientes': (context) => ClientesScreen(),
        '/processos': (context) => ProcessosScreen(),
      },
    );
  }
}
