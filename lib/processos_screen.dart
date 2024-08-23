import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'constantes_arbitraries.dart'; // Importe o arquivo com a variável LINK_BASE

class ProcessosScreen extends StatefulWidget {
  @override
  _ProcessosScreenState createState() => _ProcessosScreenState();
}

class _ProcessosScreenState extends State<ProcessosScreen> {
  List<dynamic> processos = []; // Lista para armazenar os processos
  bool isLoading = true; // Indicador de carregamento
  final _formKey = GlobalKey<FormState>(); // Chave para o formulário

  @override
  void initState() {
    super.initState();
    _loadProcessos();
  }

  // Função para carregar os processos do backend
  Future<void> _loadProcessos() async {
    final response = await http.get(Uri.parse('$LINK_BASE/processos/'));
    if (response.statusCode == 200) {
      setState(() {
        processos = jsonDecode(response.body);
        isLoading = false;
      });
    } else {
      // Tratar erros de requisição
      print('Erro ao carregar processos: ${response.statusCode}');
    }
  }

  // Função para adicionar um novo processo
  Future<void> _addProcesso(
      String categoria,
      String status,
      String notas,
      String cliente,
      ) async {
    final response = await http.post(
      Uri.parse('$LINK_BASE/processos/'),
      body: jsonEncode({
        'categoria': categoria,
        'status': status,
        'notas': notas,
        'cliente': cliente,
      }),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      _loadProcessos();
      // Limpar o formulário após a adição
      _formKey.currentState?.reset();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Processo adicionado com sucesso!')),
      );
    } else {
      // Tratar erros de requisição
      print('Erro ao adicionar processo: ${response.statusCode}');
    }
  }

  // Função para editar um processo
  Future<void> _editProcesso(
      String processoId,
      String categoria,
      String status,
      String notas,
      String cliente,
      ) async {
    final response = await http.put(
      Uri.parse('$LINK_BASE/processos/$processoId'),
      body: jsonEncode({
        'categoria': categoria,
        'status': status,
        'notas': notas,
        'cliente': cliente,
      }),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      _loadProcessos();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Processo editado com sucesso!')),
      ); // Fechar o modal após a edição
    } else {
      // Tratar erros de requisição
      print('Erro ao editar processo: ${response.statusCode}');
    }
  }

  // Função para excluir um processo
  Future<void> _deleteProcesso(String processoId) async {
    final response = await http.delete(Uri.parse('$LINK_BASE/processos/$processoId'));
    if (response.statusCode == 200) {
      _loadProcessos();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Processo removido com sucesso!')),
      );
    } else {
      // Tratar erros de requisição
      print('Erro ao excluir processo: ${response.statusCode}');
    }
  }

  // Modal para adicionar ou editar processos
  void _showProcessoModal(
      [String? processoId,
        String? categoria,
        String? status,
        String? notas,
        String? cliente]) async {
    // Variáveis para armazenar os dados do processo
    final _categoriaController = TextEditingController(text: categoria);
    final _statusController = TextEditingController(text: status);
    final _notasController = TextEditingController(text: notas);
    final _clienteController = TextEditingController(text: cliente);

    // Variável para o status selecionado
    String? _selectedStatus = status;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Permite que o modal se ajuste ao teclado
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView( // Envolvendo o Column em um SingleChildScrollView
            reverse: true, // Importantíssimo para o scroll funcionar corretamente
            child: Form(
              key: _formKey,
              child: Padding(
                padding: MediaQuery.of(context).viewInsets, // Adicione esse padding
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Campo para a categoria do processo
                    TextFormField(
                      controller: _categoriaController,
                      decoration: InputDecoration(labelText: 'Categoria'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira a categoria';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    // Campo para o status do processo
                    DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      hint: Text('Selecione o status'),
                      decoration: InputDecoration(labelText: 'Status'),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedStatus = newValue;
                        });
                      },
                      items: <String>['Em andamento', 'Concluído']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 16),
                    // Campo para as notas do processo
                    TextFormField(
                      controller: _notasController,
                      decoration: InputDecoration(labelText: 'Notas'),
                    ),
                    SizedBox(height: 16),
                    // Campo para o cliente do processo
                    TextFormField(
                      controller: _clienteController,
                      decoration: InputDecoration(labelText: 'Cliente'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o cliente';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 32),
                    // Botão para salvar as alterações
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Se o processoId for nulo, é uma adição
                          if (processoId == null) {
                            _addProcesso(
                              _categoriaController.text,
                              _selectedStatus!, // Use o _selectedStatus aqui
                              _notasController.text,
                              _clienteController.text,
                            );
                          } else {
                            // Caso contrário, é uma edição
                            _editProcesso(
                              processoId,
                              _categoriaController.text,
                              _selectedStatus!, // Use o _selectedStatus aqui
                              _notasController.text,
                              _clienteController.text,
                            );
                          }
                        }
                      },
                      child: Text(processoId == null ? 'Adicionar' : 'Editar'),
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
        title: Text('Processos'),
      ),
      resizeToAvoidBottomInset: true,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Botão para adicionar um novo processo
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                _showProcessoModal();
              },
              child: Text('Adicionar Processo'),
            ),
          ),
          // Tabela para listar os processos
          Expanded(
            child: ListView.builder(
              itemCount: processos.length,
              itemBuilder: (context, index) {
                final processo = processos[index];
                return ListTile(
                  title: Text(processo['categoria']),
                  subtitle: Text(processo['status']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          _showProcessoModal(
                            processo['_id'],
                            processo['categoria'],
                            processo['status'],
                            processo['notas'],
                            processo['cliente'],
                          );
                        },
                        icon: Icon(Icons.edit),
                      ),
                      IconButton(
                        onPressed: () {
                          _deleteProcesso(processo['_id']);
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