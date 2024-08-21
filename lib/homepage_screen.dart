import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class HomePageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MyLex'),
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
                    dataSource: [
                      SalesData('Teste 1', 300, Colors.red),
                      SalesData('Teste 2', 50, Colors.blue),
                      SalesData('Teste 3', 100, Colors.yellow),
                    ],
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