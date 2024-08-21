import 'package:flutter/material.dart';

class AgendaScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agenda'),
      ),
      body: Center(
        child: Text(
          'Tela de Agenda',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
