import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'constantes_arbitraries.dart';
import 'login_screen.dart';

class HomePageScreen extends StatefulWidget {
  @override
  _HomePageScreenState createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  List<SalesData> chartData = [];

  @override
  void initState() {
    super.initState();
    fetchProcessos();
  }

  Future<void> fetchProcessos() async {
    final response = await http.get(Uri.parse('$LINK_BASE/processos/'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      Map<String, int> statusCount = {};

      for (var process in data) {
        String status = process['status'];
        if (statusCount.containsKey(status)) {
          statusCount[status] = statusCount[status]! + 1;
        } else {
          statusCount[status] = 1;
        }
      }

      setState(() {
        chartData = statusCount.entries.map((entry) {
          return SalesData(entry.key, entry.value.toDouble(), _getColor(entry.key));
        }).toList();
      });
    } else {
      throw Exception('Failed to load processos');
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
            icon: Icon(Icons.person_add),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/cadastro'); // Tela de cadastro de usuários
            },
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login'); // Retorna para a tela de login
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: SfCircularChart(
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
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Agenda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Clientes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: 'Processos',
          ),
        ],
        selectedItemColor: Color(0xFFE7D49E),
        unselectedItemColor: Color(0xFFE7D49E),
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