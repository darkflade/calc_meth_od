import 'package:flutter/material.dart';
import 'package:calc_meth_od/logic/lab4_logic.dart';

// --- Глобальная функция для парсинга данных из контроллеров ---
List<DataPoint> _parseDataPoints(List<TextEditingController> xControllers, List<TextEditingController> yControllers) {
  print("--- Parsing data points from table ---");
  final List<DataPoint> points = [];
  for (int i = 0; i < xControllers.length; i++) {
    final x = double.tryParse(xControllers[i].text);
    final y = double.tryParse(yControllers[i].text);
    if (x == null || y == null) {
      final errorMsg = "Ошибка в таблице, строка ${i + 1}. Введите корректные числа.";
      print("Parsing error: $errorMsg");
      throw ArgumentError(errorMsg);
    }
    points.add(DataPoint(x, y));
  }
  if (points.isEmpty) {
    const errorMsg = "Таблица данных не может быть пустой.";
    print("Parsing error: $errorMsg");
    throw ArgumentError(errorMsg);
  }
  print("Successfully parsed ${points.length} points.");
  print("--- Finished parsing data points ---");
  return points;
}

// --- Главный виджет экрана с вкладками ---
class Lab4Screen extends StatelessWidget {
  const Lab4Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Лабораторная 4: Интерполяция'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Лагранж и Эйткен'),
              Tab(text: 'Ньютон (разности)'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _LagrangeAitkenView(),
            _NewtonView(),
          ],
        ),
      ),
    );
  }
}

// --- Вкладка для Лагранжа и Эйткена ---
class _LagrangeAitkenView extends StatefulWidget {
  const _LagrangeAitkenView();

  @override
  State<_LagrangeAitkenView> createState() => _LagrangeAitkenViewState();
}

class _LagrangeAitkenViewState extends State<_LagrangeAitkenView> {
  final List<TextEditingController> _xControllers = [];
  final List<TextEditingController> _yControllers = [];
  final _targetXController = TextEditingController(text: '1.43');
  final _epsilonController = TextEditingController(text: '0.001');

  String? _lagrangeResult;
  String? _aitkenResult;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final initialData = {
      1.0: 2.718, 1.1: 3.0041, 1.2: 3.3201, 1.3: 3.6692, 1.4: 4.0552,
      1.5: 4.4816, 1.6: 4.9530, 1.7: 5.4739, 1.8: 6.0496, 1.9: 6.6858, 2.0: 7.389
    };
    initialData.forEach((x, y) {
      _xControllers.add(TextEditingController(text: x.toString()));
      _yControllers.add(TextEditingController(text: y.toString()));
    });
  }

  @override
  void dispose() {
    for (var c in _xControllers) { c.dispose(); }
    for (var c in _yControllers) { c.dispose(); }
    _targetXController.dispose();
    _epsilonController.dispose();
    super.dispose();
  }

  void _calculate() {
    print("--- Starting Lagrange and Aitken calculation ---");
    setState(() {
      _lagrangeResult = null;
      _aitkenResult = null;
      _errorMessage = null;
    });

    final targetX = double.tryParse(_targetXController.text);
    final epsilon = double.tryParse(_epsilonController.text);
    if (targetX == null || epsilon == null) {
      setState(() => _errorMessage = "Проверьте точку X и точность ε.");
      print("Error: Invalid input for targetX or epsilon.");
      return;
    }
    print("Inputs: targetX = $targetX, epsilon = $epsilon");

    try {
      final dataPoints = _parseDataPoints(_xControllers, _yControllers);
      final logic = InterpolationLogic(dataPoints);

      print("\n>>> Calculating Lagrange polynomial...");
      final lResult = logic.lagrange(targetX);
      print("<<< Lagrange calculation finished. Result: $lResult");

      print("\n>>> Calculating with Aitken's scheme...");
      final aResult = logic.aitken(targetX, epsilon);
      print("<<< Aitken's scheme finished. Result: $aResult");

      setState(() {
        _lagrangeResult = "f($targetX) ≈ ${lResult.toStringAsFixed(6)}";
        _aitkenResult = "f($targetX) ≈ ${(aResult['value'] as double).toStringAsFixed(6)} (Итераций: ${aResult['iterations']})";
      });
      print("--- Lagrange and Aitken calculation finished successfully ---");

    } catch (e) {
      print("Error during calculation: $e");
      setState(() => _errorMessage = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return _InterpolationTabView(
      taskTitle: 'Сравнение Лагранжа и Эйткена',
      controls: Column(
        children: [
          TextField(
            controller: _targetXController,
            decoration: const InputDecoration(labelText: 'Точка для интерполяции (x)', border: OutlineInputBorder()),
            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _epsilonController,
            decoration: const InputDecoration(labelText: 'Точность для Эйткена (ε)', border: OutlineInputBorder()),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ],
      ),
      xControllers: _xControllers,
      yControllers: _yControllers,
      onCalculate: _calculate,
      errorMessage: _errorMessage,
      results: {
        'Полином Лагранжа': _lagrangeResult,
        'Схема Эйткена': _aitkenResult,
      },
      onAddRow: () => setState(() {
        _xControllers.add(TextEditingController(text: '0'));
        _yControllers.add(TextEditingController(text: '0'));
      }),
      onRemoveRow: () => setState(() {
        if (_xControllers.isNotEmpty) {
          _xControllers.removeLast().dispose();
          _yControllers.removeLast().dispose();
        }
      }),
    );
  }
}

// --- Вкладка для метода Ньютона ---
class _NewtonView extends StatefulWidget {
  const _NewtonView();

  @override
  State<_NewtonView> createState() => _NewtonViewState();
}

class _NewtonViewState extends State<_NewtonView> {
  final List<TextEditingController> _xControllers = [];
  final List<TextEditingController> _yControllers = [];
  final _targetXController = TextEditingController(text: '0.1, 0.8');

  String? _newtonResults;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final initialData = {
      0.0: 2.0, 0.1: 2.105, 0.2: 2.221, 0.3: 2.349, 0.4: 2.491, 0.5: 2.648,
      0.6: 2.822, 0.7: 3.013, 0.8: 3.225, 0.9: 3.459, 1.0: 3.718
    };
    initialData.forEach((x, y) {
      _xControllers.add(TextEditingController(text: x.toString()));
      _yControllers.add(TextEditingController(text: y.toString()));
    });
  }

  @override
  void dispose() {
    for (var c in _xControllers) { c.dispose(); }
    for (var c in _yControllers) { c.dispose(); }
    _targetXController.dispose();
    super.dispose();
  }

  void _calculate() {
    print("--- Starting Newton interpolation calculation ---");
    setState(() {
      _newtonResults = null;
      _errorMessage = null;
    });

    final targetPoints = _targetXController.text.split(',').map((e) => double.tryParse(e.trim())).toList();
    if (targetPoints.any((p) => p == null)) {
      setState(() => _errorMessage = "Проверьте точки для интерполяции. Формат: 0.1, 0.8");
      print("Error: Invalid input for target points.");
      return;
    }
    print("Inputs: targetPoints = $targetPoints");

    try {
      final dataPoints = _parseDataPoints(_xControllers, _yControllers);
      final logic = InterpolationLogic(dataPoints);

      print("\n>>> Calculating finite differences table...");
      final table = logic.calculateFiniteDifferences();
      print("<<< Finished calculating finite differences table.");

      final results = targetPoints.map((x) {
        if (x == null) return "Invalid point";
        print("\n>>> Calculating Newton interpolation for x = $x...");
        final val = logic.newton(x, table);
        print("<<< Newton interpolation for x = $x finished. Result: $val");
        return "f($x) ≈ ${val.toStringAsFixed(6)}";
      }).join('\n');

      setState(() { _newtonResults = results; });
      print("--- Newton interpolation calculation finished successfully ---");

    } catch (e) {
      print("Error during calculation: $e");
      setState(() => _errorMessage = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return _InterpolationTabView(
      taskTitle: 'Интерполяция по формуле Ньютона',
      controls: TextField(
        controller: _targetXController,
        decoration: const InputDecoration(
            labelText: 'Точки для контроля (через запятую)',
            border: OutlineInputBorder()
        ),
      ),
      xControllers: _xControllers,
      yControllers: _yControllers,
      onCalculate: _calculate,
      errorMessage: _errorMessage,
      results: { 'Результаты': _newtonResults },
      onAddRow: () => setState(() {
        _xControllers.add(TextEditingController(text: '0'));
        _yControllers.add(TextEditingController(text: '0'));
      }),
      onRemoveRow: () => setState(() {
        if (_xControllers.isNotEmpty) {
          _xControllers.removeLast().dispose();
          _yControllers.removeLast().dispose();
        }
      }),
    );
  }
}

// --- ОБЩИЙ ПЕРЕИСПОЛЬЗУЕМЫЙ ВИДЖЕТ ДЛЯ UI ВКЛАДКИ ---
class _InterpolationTabView extends StatelessWidget {
  final String taskTitle;
  final Widget controls;
  final List<TextEditingController> xControllers;
  final List<TextEditingController> yControllers;
  final VoidCallback onCalculate;
  final VoidCallback onAddRow;
  final VoidCallback onRemoveRow;
  final String? errorMessage;
  final Map<String, String?> results;

  const _InterpolationTabView({
    required this.taskTitle,
    required this.controls,
    required this.xControllers,
    required this.yControllers,
    required this.onCalculate,
    required this.onAddRow,
    required this.onRemoveRow,
    this.errorMessage,
    required this.results,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(taskTitle, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          controls,
          const SizedBox(height: 20),
          _EditableDataTable(
            xControllers: xControllers,
            yControllers: yControllers,
            onAddRow: onAddRow,
            onRemoveRow: onRemoveRow,
          ),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: onCalculate, child: const Text('Вычислить')),
          const SizedBox(height: 20),
          if (errorMessage != null)
            Text('Ошибка: $errorMessage', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ...results.entries.where((e) => e.value != null).map((e) => Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text('${e.key}: ${e.value}', style: Theme.of(context).textTheme.bodyLarge),
          )),
        ],
      ),
    );
  }
}

// --- Переиспользуемый виджет для редактируемой таблицы ---
class _EditableDataTable extends StatelessWidget {
  final List<TextEditingController> xControllers;
  final List<TextEditingController> yControllers;
  final VoidCallback onAddRow;
  final VoidCallback onRemoveRow;

  const _EditableDataTable({
    required this.xControllers,
    required this.yControllers,
    required this.onAddRow,
    required this.onRemoveRow,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Таблица данных", style: Theme.of(context).textTheme.titleMedium),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      color: Theme.of(context).colorScheme.error,
                      tooltip: 'Удалить последнюю строку',
                      onPressed: onRemoveRow,
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      color: Colors.green,
                      tooltip: 'Добавить новую строку',
                      onPressed: onAddRow,
                    ),
                  ],
                ),
              ],
            ),
            const Divider(),
            if (xControllers.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: Text("Нет данных. Добавьте строку."),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: xControllers.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: xControllers[index],
                            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                            decoration: InputDecoration(
                              labelText: 'Значение X',
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surfaceVariant.withAlpha(100),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: yControllers[index],
                            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                            decoration: InputDecoration(
                              labelText: 'Значение Y',
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surfaceVariant.withAlpha(100),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
