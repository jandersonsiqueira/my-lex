import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'constantes_arbitraries.dart';

class HomePageScreen extends StatefulWidget {
  @override
  _HomePageScreenState createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  List<SalesData> chartData = [];
  List<dynamic> events = [];
  bool isLoadingProcessos = true;
  bool isLoadingEvents = true;
  bool isLoadingClientes = true;
  int clientesCadastrados = 0;

  @override
  void initState() {
    super.initState();
    fetchProcessos();
    fetchEvents();
    fetchClientes();
  }

  // Função para buscar os processos e gerar o gráfico
  Future<void> fetchProcessos() async {
    try {
      final response = await http.get(Uri.parse('$LINK_BASE/processos/'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        Map<String, int> statusCount = {};

        for (var process in data) {
          String status = process['status'];
          statusCount[status] = (statusCount[status] ?? 0) + 1;
        }

        setState(() {
          chartData = statusCount.entries.map((entry) {
            return SalesData(entry.key, entry.value.toDouble(), _getColor(entry.key));
          }).toList();
          isLoadingProcessos = false;
        });
      } else {
        throw Exception('Falha ao carregar processos');
      }
    } catch (e) {
      setState(() {
        isLoadingProcessos = false;
      });
    }
  }

  // Função para buscar eventos do dia
  Future<void> fetchEvents() async {
    try {
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('yyyy-MM-dd').format(now);
      final response = await http.get(Uri.parse('$LINK_BASE/calendar/'));

      if (response.statusCode == 200) {
        List<dynamic> allEvents = jsonDecode(response.body);
        setState(() {
          events = allEvents.where((event) {
            return event['date'].toString().substring(0, 10) == formattedDate;
          }).toList();
          isLoadingEvents = false;
        });
      } else {
        throw Exception('Erro ao buscar eventos');
      }
    } catch (e) {
      setState(() {
        isLoadingEvents = false;
      });
    }
  }

  // Função para buscar o número de clientes cadastrados
  Future<void> fetchClientes() async {
    try {
      final response = await http.get(Uri.parse('$LINK_BASE/cliente/'));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          clientesCadastrados = data.length;
          isLoadingClientes = false;
        });
      } else {
        throw Exception('Erro ao buscar clientes');
      }
    } catch (e) {
      setState(() {
        isLoadingClientes = false;
      });
    }
  }

  Color _getColor(String status) {
    switch (status) {
      case 'Concluído':
        return Colors.green;
      case 'Em andamento':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MyLex'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.chat),
            onPressed: () => Navigator.pushReplacementNamed(context, '/chatbot'),
          ),
          IconButton(
            icon: Icon(Icons.person_add),
            onPressed: () => Navigator.pushReplacementNamed(context, '/cadastro'),
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            // Card com o número de clientes cadastrados
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: isLoadingClientes
                    ? Center(child: CircularProgressIndicator())
                    : ListTile(
                  title: Text('Clientes Cadastrados'),
                  subtitle: Text(clientesCadastrados.toString()),
                  leading: Icon(Icons.people, size: 40, color: Colors.blue),
                ),
              ),
            ),
            SizedBox(height: 16),
            // Gráfico de Processos
            Expanded(
              flex: 5,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: isLoadingProcessos
                      ? Center(child: CircularProgressIndicator())
                      : SfCircularChart(
                    title: ChartTitle(text: 'Seus processos da semana'),
                    legend: Legend(isVisible: true),
                    series: <CircularSeries>[
                      PieSeries<SalesData, String>(
                        dataSource: chartData,
                        xValueMapper: (SalesData data, _) => data.category,
                        yValueMapper: (SalesData data, _) => data.value,
                        pointColorMapper: (SalesData data, _) => data.color,
                        dataLabelSettings: DataLabelSettings(isVisible: true),
                      )
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            // Eventos do Dia
            Expanded(
              flex: 3,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: isLoadingEvents
                      ? Center(child: CircularProgressIndicator())
                      : events.isNotEmpty
                      ? ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Icon(Icons.event),
                        title: Text(events[index]['title']),
                        subtitle: Text('Horário: ${events[index]['time']}'),
                      );
                    },
                  )
                      : Center(child: Text('Sem eventos hoje')),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Agenda'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Clientes'),
          BottomNavigationBarItem(icon: Icon(Icons.folder), label: 'Processos'),
        ],
        selectedItemColor: Color(0xFFE7D49E),
        unselectedItemColor: Colors.white,
        backgroundColor: Colors.black,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/agenda');
          } else if (index == 1) {
            Navigator.pushNamed(context, '/clientes');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/processos');
          }
        },
      ),
    );
  }
}

class SalesData {
  SalesData(this.category, this.value, this.color);
  final String category;
  final double value;
  final Color color;
}