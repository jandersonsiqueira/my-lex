import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

import 'constantes_arbitraries.dart';

class AgendaScreen extends StatefulWidget {
  @override
  _AgendaScreenState createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  // Variáveis para o calendário
  DateTime _selectedDate = DateTime.now();
  int _currentDay = DateTime.now().day;
  int _currentMonth = DateTime.now().month;
  int _currentYear = DateTime.now().year;
  List<dynamic> _events = [];

  // Função para buscar eventos da API
  Future<void> _fetchEvents() async {
    final response = await http.get(Uri.parse('$LINK_BASE/calendar/by-date/$_currentYear/$_currentMonth'));
    final formattedDate = DateTime(_currentYear, _currentMonth, _currentDay).toString().substring(0, 10);
    final eventsForDay = _events.where((event) => event['date'].toString().substring(0, 10) == formattedDate).toList();

    if (response.statusCode == 200) {
      setState(() {
        _events = jsonDecode(response.body);
      });
    } else {
      print('Erro ao buscar eventos: ${response.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendário'),
      ),
      body: Column(
        children: [
          // Cabeçalho com mês e ano
          Container(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    setState(() {
                      _currentMonth--;
                      if (_currentMonth == 0) {
                        _currentMonth = 12;
                        _currentYear--;
                      }
                      _fetchEvents();
                    });
                  },
                ),
                Text(
                  '${DateFormat('MMMM').format(DateTime(_currentYear, _currentMonth))} - $_currentYear',
                  style: TextStyle(fontSize: 20.0),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward_ios),
                  onPressed: () {
                    setState(() {
                      _currentMonth++;
                      if (_currentMonth == 13) {
                        _currentMonth = 1;
                        _currentYear++;
                      }
                      _fetchEvents();
                    });
                  },
                ),
              ],
            ),
          ),
          // Grid do Calendário
          Expanded(
            child: CalendarGridView(
              selectedDate: _selectedDate,
              currentDay: _currentDay,
              currentMonth: _currentMonth,
              currentYear: _currentYear,
              events: _events,
              onDateSelected: (date) {
                setState(() {
                  _selectedDate = date;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CalendarGridView extends StatelessWidget {
  final DateTime selectedDate;
  final int currentDay;
  final int currentMonth;
  final int currentYear;
  final List<dynamic> events;
  final Function(DateTime) onDateSelected;

  const CalendarGridView({
    Key? key,
    required this.selectedDate,
    required this.currentDay,
    required this.currentMonth,
    required this.currentYear,
    required this.events,
    required this.onDateSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firstDayOfMonth = DateTime(currentYear, currentMonth);
    final firstDayOfMonthWeekday = firstDayOfMonth.weekday;
    final daysInMonth = DateTime(currentYear, currentMonth + 1, 0).day;
    final _formKey = GlobalKey<FormState>();
    String? newEventTitle;

    return GridView.count(
      crossAxisCount: 7,
      children: List.generate(42, (index) {
        final day = index - firstDayOfMonthWeekday + 1;
        if (day > 0 && day <= daysInMonth) {
          final formattedDate = DateTime(currentYear, currentMonth, day).toString().substring(0, 10);
          final eventsForDay = events.where((event) => event['date'].toString().substring(0, 10) == formattedDate).toList();

          return GestureDetector(
            onTap: () {
              // Chama o showDialog quando a célula é tocada
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  final selectedDay = DateTime(currentYear, currentMonth, day); // Guarda a data da célula clicada
                  return AlertDialog(
                    title: Text('Eventos do Dia ${selectedDay.day}/${selectedDay.month}/${selectedDay.year}'),
                    content: Form(
                      key: _formKey, // Adicione um key para o Form
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Exibe os eventos para o dia selecionado
                          if (eventsForDay.isNotEmpty)
                            for (var event in eventsForDay)
                            // Dentro do loop 'for (var event in eventsForDay)'
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(event['title']), // Texto do evento
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              // Lógica para editar o evento
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  String? newEventTitle;
                                                  final _formKey = GlobalKey<FormState>();
                                                  return AlertDialog(
                                                    title: Text('Editar Evento'),
                                                    content: Form(
                                                      key: _formKey,
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          // Campo para inserir o novo título do evento
                                                          TextFormField(
                                                            initialValue: event['title'], // Define o valor inicial com o título atual do evento
                                                            decoration: InputDecoration(labelText: 'Título do Evento'),
                                                            onSaved: (value) {
                                                              newEventTitle = value; // Salva o novo título do evento
                                                            },
                                                          ),
                                                          ElevatedButton(
                                                            onPressed: () {
                                                              // Salva os dados do formulário
                                                              final form = _formKey.currentState;
                                                              if (form != null) {
                                                                form.save();
                                                              }

                                                              // Chame _editEvent com o novo título
                                                              _editEvent(event['_id'], newEventTitle!, selectedDay );

                                                              Navigator.pop(context); // Fecha o modal
                                                            },
                                                            child: Text('Salvar'),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(context);
                                                        },
                                                        child: Text('Fechar'),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                            icon: Icon(Icons.edit),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              // Lógica para excluir o evento
                                              _deleteEvent(event['_id']);
                                              Navigator.pop(context); // Fecha o modal
                                            },
                                            icon: Icon(Icons.delete),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8.0), // Espaçamento entre os eventos
                                ],
                              ),
                          if (eventsForDay.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text('Nenhum evento para este dia.'),
                            ),
                          // Campo para inserir o título do evento
                          TextFormField(
                            decoration: InputDecoration(labelText: 'Título do Evento'),
                            onSaved: (value) {
                              newEventTitle = value;
                            },
                          ),

                          // Botão "Novo Evento"
                          ElevatedButton(
                            onPressed: () {
                              // Salva os dados do formulário
                              final form = _formKey.currentState;
                              if (form != null) {
                                form.save();
                              }

                              _createEvent(selectedDay, newEventTitle!);

                              Navigator.pop(context);
                            },
                            child: Text('Criar Novo Evento'),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Fechar'),
                      ),
                    ],
                  );
                },
              );
            },
            child: Container(
              decoration: BoxDecoration(
                border: selectedDate == DateTime(currentYear, currentMonth, day) ? Border.all(color: Colors.blue) : null,
              ),
              padding: EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$day',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: selectedDate == DateTime(currentYear, currentMonth, day) ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  if (eventsForDay.isNotEmpty)
                    Container(
                      width: 8.0,
                      height: 8.0,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          );
        } else {
          return Container();
        }
      }),
    );
  }
}

// Função para enviar o novo evento para a API
Future<void> _createEvent(DateTime date, String title) async {
  final response = await http.post(
    Uri.parse('$LINK_BASE/calendar/'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, dynamic>{
      'date': date.toIso8601String(),
      'title': title,
    }),
  );

  if (response.statusCode == 200) {
    print('Evento criado com sucesso.');
  } else {
    print('Erro ao criar evento: ${response.statusCode}');
  }
}

Future<void> _editEvent(String eventId, String title, DateTime date) async {
  final response = await http.put(
    Uri.parse('$LINK_BASE/calendar/$eventId'),
    body: jsonEncode({
      'title': title,
      'date': date.toIso8601String(),
    }),
    headers: {'Content-Type': 'application/json'},
  );

  if (response.statusCode == 200) {
    print('Evento editado com sucesso.');
  } else {
    print('Erro ao editar evento: ${response.statusCode}');
  }
}

Future<void> _deleteEvent(String eventId) async {
  final response = await http.delete(Uri.parse('$LINK_BASE/calendar/$eventId'));

  if (response.statusCode == 200) {
    print('Evento excluído com sucesso.');
  } else {
    print('Erro ao excluir evento: ${response.statusCode}');
  }
}