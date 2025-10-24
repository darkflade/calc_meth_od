import 'package:calc_meth_od/logic/lab5_logic.dart' as logic;
import 'package:flutter/material.dart';

class Lab5Screen extends StatefulWidget {
  const Lab5Screen({super.key});

  @override
  State<Lab5Screen> createState() => _Lab5ScreenState();
}

class _Lab5ScreenState extends State<Lab5Screen> {
  final _aController = TextEditingController(text: '1.0');
  final _bController = TextEditingController(text: '2.0');
  final _epsController = TextEditingController(text: '0.00001');
  final _gaussNController = TextEditingController(text: '4');

  String? _simpsonResult;
  String? _gaussResult;
  String? _monteCarloResult;
  String? _errorMessage;

  void _calculateSimpsonAndGauss() {
    setState(() {
      _simpsonResult = null;
      _gaussResult = null;
      _errorMessage = null;
    });

    final a = double.tryParse(_aController.text);
    final b = double.tryParse(_bController.text);
    final eps = double.tryParse(_epsController.text);
    final nGauss = int.tryParse(_gaussNController.text);

    if (a == null || b == null || eps == null || nGauss == null) {
      setState(() => _errorMessage = 'Проверьте введенные данные. Все поля должны быть корректными числами.');
      return;
    }

    try {
      // --- Вычисление методом Симпсона ---
      final simpsonData = logic.simpsonWithRunge(a, b, eps);
      final simpsonValue = simpsonData['value'] as double;
      final simpsonN = simpsonData['n'] as int;
      
      // --- Вычисление методом Гаусса ---
      final gaussData = logic.gaussTest(a, b, nGauss, eps);

      setState(() {
        _simpsonResult = 'I ≈ ${simpsonValue.toStringAsFixed(8)} (n = $simpsonN)';
        _gaussResult = gaussData;
      });

    } catch (e) {
      setState(() => _errorMessage = 'Ошибка при вычислении: ${e.toString()}');
    }
  }

  void _calculateMonteCarlo() {
    setState(() {
      _monteCarloResult = null;
      _errorMessage = null;
    });

    try {
      final mcLogic = logic.MonteCarloLogic();
      final result = mcLogic.run();
      setState(() {
        _monteCarloResult = result;
      });
    } catch (e) {
      setState(() => _errorMessage = 'Ошибка при вычислении Монте-Карло: ${e.toString()}');
    }
  }

  @override
  void dispose() {
    _aController.dispose();
    _bController.dispose();
    _epsController.dispose();
    _gaussNController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Лабораторная 5: Интегрирование'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSimpsonGaussCard(),
            const SizedBox(height: 24),
            _buildMonteCarloCard(),
            const SizedBox(height: 24),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text('Ошибка: $_errorMessage', style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpsonGaussCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Интеграл от x * sin(1/x^3) dx',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildInputFields(),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _calculateSimpsonAndGauss, child: const Text('Вычислить Симпсона и Гаусса')),
            if (_simpsonResult != null || _gaussResult != null)
              _buildResults(),
          ],
        ),
      ),
    );
  }

  Widget _buildMonteCarloCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Интеграл ∫∫∫ x dx dy dz',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'x∈[1,5], y∈[2,4], z∈[1,2]',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _calculateMonteCarlo, child: const Text('Вычислить Монте-Карло')),
            if (_monteCarloResult != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Результаты', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(_monteCarloResult!, style: Theme.of(context).textTheme.bodyLarge),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Параметры', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _aController,
                decoration: const InputDecoration(labelText: 'Нижний предел (a)', border: OutlineInputBorder()),
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: _bController,
                decoration: const InputDecoration(labelText: 'Верхний предел (b)', border: OutlineInputBorder()),
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _epsController,
          decoration: const InputDecoration(labelText: 'Точность (ε) для Симпсона', border: OutlineInputBorder()),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _gaussNController,
          decoration: const InputDecoration(labelText: 'Начальное n для Гаусса (от 2)', border: OutlineInputBorder()),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildResults() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Результаты', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          if (_simpsonResult != null)
            ListTile(
              title: const Text('Метод Симпсона (с прав. Рунге)'),
              subtitle: Text(_simpsonResult!, style: Theme.of(context).textTheme.bodyLarge),
            ),
          const SizedBox(height: 16),
          if (_gaussResult != null)
            ListTile(
              title: const Text('Квадратура Гаусса (3 итерации)'),
              subtitle: Text(_gaussResult!, style: Theme.of(context).textTheme.bodyLarge),
            ),
        ],
      ),
    );
  }
}
