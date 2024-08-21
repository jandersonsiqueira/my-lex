import 'package:flutter/material.dart';

class ProcessosScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Processos'),
      ),
      body: Center(
        child: Text(
          'Tela de Processos',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
