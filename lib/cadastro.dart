import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'constantes_arbitraries.dart';

class CadastroScreen extends StatefulWidget {
  @override
  _CadastroScreenState createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  List<dynamic> usuarios = [];
  bool isLoading = true;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadUsuarios();
  }

  // Função para carregar os usuários do backend
  Future<void> _loadUsuarios() async {
    final response = await http.get(Uri.parse('$LINK_BASE/login'));
    if (response.statusCode == 200) {
      setState(() {
        usuarios = jsonDecode(response.body);
        isLoading = false;
      });
    } else {
      print('Erro ao carregar usuários: ${response.statusCode}');
    }
  }

  // Função para adicionar um novo usuário
  Future<void> _addUsuario(String user, String password) async {

    final response = await http.post(
      Uri.parse('$LINK_BASE/login/'),
      body: jsonEncode({
        'user': user,
        'password': password,
      }),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      _loadUsuarios();
      _formKey.currentState?.reset();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Usuário adicionado com sucesso!')),
      );
    } else {
      print('Erro ao adicionar usuário: ${response.statusCode}');
    }
  }

  // Função para editar um usuário
  Future<void> _editUsuario(String userId, String user, String password) async {

    final response = await http.put(
      Uri.parse('$LINK_BASE/login/$userId'),
      body: jsonEncode({
        'user': user,
        'password': password,
      }),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      _loadUsuarios();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Usuário editado com sucesso!')),
      );
    } else {
      print('Erro ao editar usuário: ${response.statusCode}');
    }
  }

  Future<void> _deleteUsuario(String userId) async {
    
    final response = await http.delete(Uri.parse('$LINK_BASE/login/$userId'));
    if (response.statusCode == 200) {
      _loadUsuarios();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Usuário removido com sucesso!')),
      );
    } else {
      // Tratar erros de requisição
      print('Erro ao excluir usuário: ${response.statusCode}');
    }
  }

  // Modal para adicionar ou editar usuários
  void _showUsuarioModal([String? userId, String? user, String? password]) async {
    final _userController = TextEditingController(text: user);
    final _passwordController = TextEditingController(text: password);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            reverse: true,
            child: Form(
              key: _formKey,
              child: Padding(
                padding: MediaQuery.of(context).viewInsets,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _userController,
                      decoration: InputDecoration(labelText: 'Usuário'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o usuário';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(labelText: 'Senha'),
                      obscureText: true, // Para ocultar a senha
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira a senha';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          if (userId == null) {
                            _addUsuario(
                              _userController.text,
                              _passwordController.text,
                            );
                          } else {
                            _editUsuario(
                              userId,
                              _userController.text,
                              _passwordController.text,
                            );
                          }
                        }
                      },
                      child: Text(userId == null ? 'Adicionar' : 'Editar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastro de Usuários'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/homepage');
          },
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                _showUsuarioModal();
              },
              child: Text('Adicionar Usuário'),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: usuarios.length,
              itemBuilder: (context, index) {
                final usuario = usuarios[index];
                return ListTile(
                  title: Text(usuario['user']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          _showUsuarioModal(
                            usuario['_id'],
                            usuario['user'],
                            usuario['password'],
                          );
                        },
                        icon: Icon(Icons.edit),
                      ),
                      IconButton(
                        onPressed: () {
                          _deleteUsuario(usuario['_id']);
                        },
                        icon: Icon(Icons.delete),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
