import 'dart:convert';

import 'package:flutter/material.dart';
import 'constantes_arbitraries.dart';
import 'homepage_screen.dart'; // Importe a tela de homepage
import 'package:http/http.dart' as http; // Importe a biblioteca http

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MyLex'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Seja bem vindo ao MyLex',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 40),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Usuário',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, informe seu login';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, informe sua senha';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // Mostrar Snackbar de carregamento
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Carregando...')),
                    );

                    // Obter os dados do formulário
                    String username = _usernameController.text;
                    String password = _passwordController.text;

                    // Fazer a requisição à API
                    final response = await http.get(
                      Uri.parse('$LINK_BASE/login/login?user=$username&password=$password'),
                      headers: {'Content-Type': 'application/json'},
                    );

                    // Verificar o status da requisição
                    if (response.statusCode == 200) {
                      // Login válido, navegar para a homepage
                      Navigator.pushReplacementNamed(context, '/homepage');
                    } else {
                      // Login inválido, mostrar mensagem de erro
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Login ou senha inválidos')),
                      );
                    }
                  }
                },
                child: Text('Entrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}