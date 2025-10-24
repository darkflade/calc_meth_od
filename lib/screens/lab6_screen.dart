import 'package:calc_meth_od/logic/lab6_logic.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class Lab6Screen extends StatefulWidget {
  const Lab6Screen({super.key});

  @override
  State<Lab6Screen> createState() => _Lab6ScreenState();
}

class _Lab6ScreenState extends State<Lab6Screen> {
  final _solver = CauchyProblemSolver();
  List<MethodResult>? _results;
  double _h = 0.1;

  final List<Color> _colors = [
    Colors.blueAccent,
    Colors.lightGreenAccent,
    Colors.orangeAccent,
    Colors.purpleAccent,
    Colors.redAccent,
    Colors.cyan,
  ];

  void _calculate() {
    setState(() {
      _results = _solver.runAll(_h);
    });
  }

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  Widget _formatTextToLATEX(String text) {
    final spans = <InlineSpan>[];
    final regex = RegExp(r'_(\{.*?\}|[0-9]+)|\^(\{.*?\}|[0-9]+)');
    int last = 0;

    for (final match in regex.allMatches(text)) {
      spans.add(TextSpan(text: text.substring(last, match.start)));

      if (match.group(1) != null) {
        final sub = match.group(1)!.replaceAll(RegExp(r'[\{\}]'), '');
        spans.add(
          WidgetSpan(
            baseline: TextBaseline.alphabetic,
            alignment: PlaceholderAlignment.bottom,
            child: Text(sub, style: const TextStyle(fontSize: 10)),
          ),
        );
      } else if (match.group(2) != null) {
        final sup = match.group(2)!.replaceAll(RegExp(r'[\{\}]'), '');
        spans.add(
          WidgetSpan(
            baseline: TextBaseline.alphabetic,
            alignment: PlaceholderAlignment.aboveBaseline,
            child: Text(sup, style: const TextStyle(fontSize: 10)),
          ),
        );
      }
      last = match.end;
    }

    if (last < text.length) spans.add(TextSpan(text: text.substring(last)));

    return RichText(text: TextSpan(style: const TextStyle(color: Colors.black), children: spans));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Лабораторная 6: Задача Коши'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Результаты'),
              Tab(text: 'График'),
            ],
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.grey.shade100, Colors.grey.shade300],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: _results == null
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
            children: [
              _buildResultsTable(),
              _buildChart(),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _calculate,
          icon: const Icon(Icons.calculate),
          label: const Text("Пересчитать"),
        ),
        bottomNavigationBar: _buildControls(),
      ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Шаг (h):',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 16),
          DropdownButton<double>(
            value: _h,
            items: [0.1, 0.01].map((h) {
              return DropdownMenuItem<double>(
                value: h,
                child: Text(h.toString()),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _h = value;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildResultsTable() {
    // считаем средние ошибки
    final maeValues = _results!.map((r) {
      final avgError = r.points.map((p) => p.error).reduce((a, b) => a + b) / r.points.length;
      return {'method': r.methodName, 'scheme': r.scheme, 'mae': avgError};
    }).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.grey.shade200),
                dataRowColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.hovered)) {
                    return Colors.blue.withOpacity(0.05);
                  }
                  return Colors.transparent;
                }),
                columns: const [
                  DataColumn(label: Text('Метод')),
                  DataColumn(label: Text('x')),
                  DataColumn(label: Text('y (прибл.)')),
                  DataColumn(label: Text('y (точное)')),
                  DataColumn(label: Text('|y - y_exact|')),
                ],
                rows: _results!.expand((result) {
                  final color = Colors.primaries[_results!.indexOf(result) % Colors.primaries.length]
                      .shade50; // подсветка по методам
                  return result.points.map((point) {
                    return DataRow(
                      color: WidgetStateProperty.all(color),
                      cells: [
                        DataCell(Text(result.methodName)),
                        DataCell(Text(point.x.toStringAsFixed(2))),
                        DataCell(Text(point.yApprox.toStringAsFixed(6))),
                        DataCell(Text(point.yExact.toStringAsFixed(6))),
                        DataCell(Text(point.error.toStringAsFixed(8))),
                      ],
                    );
                  });
                }).toList(),
              ),
              const SizedBox(height: 24),
              // таблица MAE
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade100,
                ),
                padding: const EdgeInsets.all(8),
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(Colors.blue.shade50),
                  columns: const [
                    DataColumn(label: Text('Метод')),
                    DataColumn(label: Text('Разностная схема')),
                    DataColumn(label: Text('Среднее абсолютное отклонение (MAE)')),
                  ],
                  rows: maeValues.map((e) {
                    final schemeText = e['scheme'] as String? ?? 'Scheme was lost';
                    return DataRow(cells: [
                      DataCell(Text(e['method'] as String)),
                      DataCell(_formatTextToLATEX(schemeText)),
                      DataCell(Text((e['mae'] as double).toStringAsExponential(4))),
                    ]);
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChart() {
    final exactPoints =
    _results![0].points.map((p) => FlSpot(p.x, p.yExact)).toList();

    final exactLine = LineChartBarData(
      spots: exactPoints,
      isCurved: true,
      color: Colors.black,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(show: false),
    );

    final lines = _results!.asMap().entries.map((entry) {
      final i = entry.key;
      final result = entry.value;
      final color = _colors[i % _colors.length];
      final spots = result.points.map((p) => FlSpot(p.x, p.yApprox)).toList();
      return LineChartBarData(
        spots: spots,
        isCurved: true,
        color: color,
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: 0.1,
                    verticalInterval: 0.1,
                    getDrawingHorizontalLine: (value) => FlLine(
                        color: Colors.grey.withOpacity(0.3), strokeWidth: 1)),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                        showTitles: true, reservedSize: 40, interval: 0.1),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                        showTitles: true, reservedSize: 30, interval: 0.1),
                  ),
                ),
                borderData: FlBorderData(show: true),
                lineBarsData: [exactLine, ...lines],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    //tooltipBgColor: Colors.white70,
                    getTooltipItems: (spots) => spots.map((s) {
                      final name = s.barIndex == 0
                          ? 'Точное решение'
                          : _results![s.barIndex - 1].methodName;
                      return LineTooltipItem(
                        '$name\nx=${s.x.toStringAsFixed(2)}, '
                            'y=${s.y.toStringAsFixed(4)}',
                        TextStyle(
                          color: s.bar.color,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildLegendItem('Точное решение', Colors.black),
              ..._results!.asMap().entries.map((entry) {
                final i = entry.key;
                final method = entry.value.methodName;
                return _buildLegendItem(method, _colors[i % _colors.length]);
              }),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String name, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 16, height: 16, color: color, margin: const EdgeInsets.only(right: 6)),
        Text(name, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
