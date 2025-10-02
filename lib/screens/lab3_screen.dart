import 'package:flutter/material.dart';
import 'dart:math';
import 'package:calc_meth_od/logic/lab3_logic.dart';

class Lab3Screen extends StatelessWidget {
  const Lab3Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Численные методы'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Метод Ньютона'),
              Tab(text: 'Метод Половинного Деления'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            // Виджет для первой задачи
            _NewtonTaskView(),
            // Виджет для второй задачи
            _BisectionTaskView(),
          ],
        ),
      ),
    );
  }
}

// --- Виджет для Задачи 1: Метод Ньютона ---
class _NewtonTaskView extends StatefulWidget {
  const _NewtonTaskView();

  @override
  State<_NewtonTaskView> createState() => _NewtonTaskViewState();
}

class _NewtonTaskViewState extends State<_NewtonTaskView> {
  final _initialApproxController = TextEditingController(text: '0.5');
  final _accuracyController = TextEditingController(text: '0.0001');
  Map<String, double>? _result;
  String? _errorMessage;

  // Функция для задачи 1: x^3 + 2x - 1 = 0
  double f(double x) => pow(x, 3) + 2 * x - 1;
  // Ее производная: 3x^2 + 2
  double df(double x) => 3 * pow(x, 2) + 2;

  void _calculate() {
    final initialApprox = double.tryParse(_initialApproxController.text);
    final accuracy = double.tryParse(_accuracyController.text);

    if (initialApprox == null || accuracy == null || accuracy <= 0) {
      setState(() {
        _errorMessage = "Пожалуйста, введите корректные числовые значения.\nТочность должна быть > 0.";
        _result = null;
      });
      return;
    }

    // Используем нашу гибкую логику
    final logic = Lab3Logic(f: f, df: df);

    try {
      final res = logic.newtonMethod(initialApprox, accuracy);
      setState(() {
        _result = res;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _result = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Уравнение: x³ + 2x - 1 = 0', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
          TextField(
            controller: _initialApproxController,
            decoration: const InputDecoration(labelText: 'Начальное приближение (x₀)', border: OutlineInputBorder()),
            keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _accuracyController,
            decoration: const InputDecoration(labelText: 'Точность (ε)', border: OutlineInputBorder()),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _calculate, child: const Text('Вычислить')),
          const SizedBox(height: 20),
          if (_result != null)
            Text(
              'Результат:\nКорень ≈ ${_result!['root']!.toStringAsFixed(6)}\nИтераций: ${_result!['iterations']!.toInt()}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          if (_errorMessage != null)
            Text(
              'Ошибка: $_errorMessage',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
        ],
      ),
    );
  }
}


// ... (весь остальной код остается без изменений) ...

// --- Виджет для Задачи 2: Метод Половинного Деления ---
class _BisectionTaskView extends StatefulWidget {
  const _BisectionTaskView();

  @override
  State<_BisectionTaskView> createState() => _BisectionTaskViewState();
}

class _BisectionTaskViewState extends State<_BisectionTaskView> {
  final _aController = TextEditingController(text: '-10'); // Расширим интервал для поиска
  final _bController = TextEditingController(text: '10');
  // ---> ДОБАВЛЕНО: Контроллер для шага
  final _stepController = TextEditingController(text: '0.1');
  final _accuracyController = TextEditingController(text: '0.0001');

  // ---> ИЗМЕНЕНО: Храним список результатов
  List<Map<String, double>>? _results;
  String? _errorMessage;

  // Функция для задачи 2: x^2 - 16 = 0
  double f(double x) => pow(x, 2) - 16;

  void _calculate() {
    final a = double.tryParse(_aController.text);
    final b = double.tryParse(_bController.text);
    final step = double.tryParse(_stepController.text); // ---> Считываем шаг
    final accuracy = double.tryParse(_accuracyController.text);

    if (a == null || b == null || step == null || accuracy == null || accuracy <= 0 || step <= 0) {
      setState(() {
        _errorMessage = "Пожалуйста, введите корректные положительные числа для точности и шага.";
        _results = null;
      });
      return;
    }

    final logic = Lab3Logic(f: f);

    try {
      // ---> ИЗМЕНЕНО: Вызываем новый метод для поиска всех корней
      final res = logic.findAllRootsBisection(a, b, step, accuracy);
      setState(() {
        _results = res;
        _errorMessage = null;
      });
    } catch(e) {
      setState(() {
        _errorMessage = e.toString();
        _results = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text('Уравнение: x² - 16 = 0', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
          TextField(
            controller: _aController,
            decoration: const InputDecoration(labelText: 'Начало интервала поиска (a)', border: OutlineInputBorder()),
            keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _bController,
            decoration: const InputDecoration(labelText: 'Конец интервала поиска (b)', border: OutlineInputBorder()),
            keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
          ),
          const SizedBox(height: 16),
          // ---> ДОБАВЛЕНО: Поле для ввода шага
          TextField(
            controller: _stepController,
            decoration: const InputDecoration(labelText: 'Шаг сканирования', border: OutlineInputBorder()),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _accuracyController,
            decoration: const InputDecoration(labelText: 'Точность (ε)', border: OutlineInputBorder()),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _calculate, child: const Text('Найти все корни')),
          const SizedBox(height: 20),
          // ---> ИЗМЕНЕНО: Отображение списка результатов
          if (_results != null)
            _results!.isEmpty
                ? Text('Корни не найдены на заданном интервале.', style: Theme.of(context).textTheme.titleMedium)
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Найденные корни:', style: Theme.of(context).textTheme.titleMedium),
                for (final result in _results!)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                        'Корень ≈ ${result['root']!.toStringAsFixed(6)} (Итераций: ${result['iterations']!.toInt()})'
                    ),
                  ),
              ],
            ),
          if (_errorMessage != null)
            Text(
              'Ошибка: $_errorMessage',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
        ],
      ),
    );
  }
}