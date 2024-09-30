import 'dart:convert';
import 'dart:async'; // Import necessário para o TimeoutException
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

                    try {
                      // Fazer a requisição à API com timeout de 10 segundos
                      final response = await http
                          .get(
                        Uri.parse('$LINK_BASE/login/login?user=$username&password=$password'),
                        headers: {'Content-Type': 'application/json'},
                      )
                          .timeout(Duration(seconds: 10)); // Timeout de 10 segundos

                      // Verificar o status da requisição
                      if (response.statusCode == 200) {
                        // Login válido, navegar para a homepage
                        Navigator.pushReplacementNamed(context, '/homepage');
                      } else {
                        // Login inválido, mostrar mensagem de erro em vermelho
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Login ou senha inválidos'),
                            backgroundColor: Colors.red, // Cor de fundo vermelha
                          ),
                        );
                      }
                    } on TimeoutException {
                      // Timeout, mostrar Snackbar de serviço indisponível em vermelho
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Serviço indisponível. Tente novamente mais tarde.'),
                          backgroundColor: Colors.red, // Cor de fundo vermelha
                        ),
                      );
                    } catch (e) {
                      // Outro erro (exemplo: falha na conexão com o servidor)
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erro inesperado: $e'),
                          backgroundColor: Colors.red, // Cor de fundo vermelha
                        ),
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
