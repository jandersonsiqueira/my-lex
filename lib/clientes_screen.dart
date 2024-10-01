import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'constantes_arbitraries.dart'; // Importe o arquivo com a variável LINK_BASE

class ClientesScreen extends StatefulWidget {
  @override
  _ClientesScreenState createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  List<dynamic> clientes = []; // Lista para armazenar os clientes
  bool isLoading = true; // Indicador de carregamento
  final _formKey = GlobalKey<FormState>(); // Chave para o formulário

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  // Função para carregar os clientes do backend
  Future<void> _loadClients() async {
    final response = await http.get(Uri.parse('$LINK_BASE/cliente/'));
    if (response.statusCode == 200) {
      setState(() {
        clientes = jsonDecode(response.body);
        isLoading = false;
      });
    } else {
      // Tratar erros de requisição
      print('Erro ao carregar clientes: ${response.statusCode}');
    }
  }

  // Função para adicionar um novo cliente
  Future<void> _addClient(
      String nomeCompleto,
      String email,
      String telefone,
      String processo,
      ) async {
    final response = await http.post(
      Uri.parse('$LINK_BASE/cliente/'),
      body: jsonEncode({
        'nomeCompleto': nomeCompleto,
        'email': email,
        'telefone': telefone,
        'processo': processo,
      }),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      _loadClients();
      // Limpar o formulário após a adição
      _formKey.currentState?.reset();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cliente adicionado com sucesso!')),
      );
    } else {
      // Tratar erros de requisição
      print('Erro ao adicionar cliente: ${response.statusCode}');
    }
  }

  // Função para editar um cliente
  Future<void> _editClient(String clientId,
      String nomeCompleto, String email, String telefone, String processo) async {
    final response = await http.put(
      Uri.parse('$LINK_BASE/cliente/$clientId'),
      body: jsonEncode({
        'nomeCompleto': nomeCompleto,
        'email': email,
        'telefone': telefone,
        'processo': processo,
      }),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      _loadClients();
      Navigator.pop(context); // Fechar o modal após a edição
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cliente editado com sucesso!')),
      );
    } else {
      // Tratar erros de requisição
      print('Erro ao editar cliente: ${response.statusCode}');
    }
  }

  // Função para excluir um cliente
  Future<void> _deleteClient(String clientId) async {
    final response = await http.delete(Uri.parse('$LINK_BASE/cliente/$clientId'));
    if (response.statusCode == 200) {
      _loadClients();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cliente removido com sucesso!')),
      );
    } else {
      // Tratar erros de requisição
      print('Erro ao excluir cliente: ${response.statusCode}');
    }
  }

  // Modal para adicionar ou editar clientes
  void _showClientModal(
      [String? clientId, String? nomeCompleto, String? email, String? telefone, String? processo]) async {
    // Variáveis para armazenar os dados do cliente
    final _nomeCompletoController = TextEditingController(text: nomeCompleto);
    final _emailController = TextEditingController(text: email);
    final _telefoneController = TextEditingController(text: telefone);
    final _processoController = TextEditingController(text: processo);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            reverse: true,// Envolvendo o Column em um SingleChildScrollView
            child: Form(
              key: _formKey,
              child: Padding(
                padding: MediaQuery.of(context).viewInsets,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nomeCompletoController,
                      decoration: InputDecoration(labelText: 'Nome Completo'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o nome completo';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(labelText: 'Email'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o email';
                        }
                        if (!value.contains('@')) {
                          return 'Email inválido';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _telefoneController,
                      decoration: InputDecoration(labelText: 'Telefone'),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _processoController,
                      decoration: InputDecoration(labelText: 'Processo'),
                    ),
                    SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Se o clientId for nulo, é uma adição
                          if (clientId == null) {
                            _addClient(
                              _nomeCompletoController.text,
                              _emailController.text,
                              _telefoneController.text,
                              _processoController.text,
                            );
                          } else {
                            // Caso contrário, é uma edição
                            _editClient(
                              clientId,
                              _nomeCompletoController.text,
                              _emailController.text,
                              _telefoneController.text,
                              _processoController.text,
                            );
                          }
                        }
                      },
                      child: Text(clientId == null ? 'Adicionar' : 'Editar'),
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

  void _generateReport() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Relatório de Clientes', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              children: clientes.map((cliente) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cliente['nomeCompleto'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.black, // Cor do nome
                          ),
                        ),
                        SizedBox(height: 8),
                        _buildInfoRow(Icons.email, cliente['email'], 'E-mail'),
                        SizedBox(height: 4),
                        _buildInfoRow(Icons.phone, cliente['telefone'], 'Telefone'),
                        SizedBox(height: 4),
                        _buildInfoRow(Icons.business, cliente['processo'], 'Processo'),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              child: Text('Fechar', style: TextStyle(color: Colors.black)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

// Função para criar uma linha de informações com ícone
  Widget _buildInfoRow(IconData icon, String info, String title) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.black),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            info,
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
        ),
        Text(
          title,
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Clientes'),
      ),
      resizeToAvoidBottomInset: true,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _showClientModal();
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add), // Ícone de adicionar
                      SizedBox(width: 8), // Espaçamento entre o ícone e o texto
                      Text('Adicionar Cliente'),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _generateReport();
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.print), // Ícone de adicionar
                      SizedBox(width: 8), // Espaçamento entre o ícone e o texto
                      Text('Gerar Relatório'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Tabela para listar os clientes
          Expanded(
            child: ListView.builder(
              itemCount: clientes.length,
              itemBuilder: (context, index) {
                final cliente = clientes[index];
                return ListTile(
                  title: Text(cliente['nomeCompleto']),
                  subtitle: Text(cliente['email']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          _showClientModal(
                            cliente['_id'],
                            cliente['nomeCompleto'],
                            cliente['email'],
                            cliente['telefone'],
                            cliente['processo'],
                          );
                        },
                        icon: Icon(Icons.edit),
                      ),
                      IconButton(
                        onPressed: () {
                          _deleteClient(cliente['_id']);
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