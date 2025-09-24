// lib/screens/lab2_screen.dart
import 'package:flutter/material.dart';
import '../logic/lab2_logic.dart'; // Ensure this path is correct

class Lab2Screen extends StatefulWidget {
  const Lab2Screen({super.key, required this.title});

  final String title;

  @override
  State<Lab2Screen> createState() => _Lab2ScreenState();
}

class _Lab2ScreenState extends State<Lab2Screen> {
  // Default values
  List<List<double>> _initialMatrixA = [
    [5, 0, 1],
    [2, 6, -2],
    [-3, 2, 10],
  ];
  List<double> _initialVectorF = [11, 8, 6];
  List<double> _initialApproximationX0 = [0, 0, 0];
  double _tolerance = 0.001;
  int _maxIterations = 100;

  Map<String, dynamic>? _jacobiResult;
  Map<String, dynamic>? _gaussSeidelResult;
  String _errorMessage = '';
  String _diagonalDominanceMessage = '';

  late int _matrixSize;
  late List<List<TextEditingController>> _matrixAControllers;
  late List<TextEditingController> _vectorFControllers;
  late List<TextEditingController> _initialApproxControllers;
  late TextEditingController _toleranceController;
  late TextEditingController _maxIterationsController;

  @override
  void initState() {
    super.initState();
    _matrixSize = _initialMatrixA.length;
    _initializeControllers();
  }

  void _initializeControllers() {
    _matrixAControllers = List.generate(
      _matrixSize,
      (i) => List.generate(
        _matrixSize,
        (j) => TextEditingController(
            text: (i < _initialMatrixA.length && j < _initialMatrixA[i].length)
                ? _initialMatrixA[i][j].toString()
                : '0.0'),
      ),
    );

    _vectorFControllers = List.generate(
      _matrixSize,
      (i) => TextEditingController(
          text: (i < _initialVectorF.length) ? _initialVectorF[i].toString() : '0.0'),
    );

    _initialApproxControllers = List.generate(
      _matrixSize,
      (i) => TextEditingController(
          text: (i < _initialApproximationX0.length)
              ? _initialApproximationX0[i].toString()
              : '0.0'),
    );

    _toleranceController = TextEditingController(text: _tolerance.toString());
    _maxIterationsController = TextEditingController(text: _maxIterations.toString());

    if (mounted) {
      setState(() {});
    }
  }

  void _updateMatrixSize(String value) {
    final size = int.tryParse(value);
    if (size != null && size > 0 && size != _matrixSize) {
      setState(() {
        _matrixSize = size;
        // Reset matrices and vectors with new default sizes
        _initialMatrixA = List.generate(
            _matrixSize, (i) => List.generate(_matrixSize, (j) => (i == j ? 1.0 : 0.0)));
        _initialVectorF = List.filled(_matrixSize, 0.0);
        _initialApproximationX0 = List.filled(_matrixSize, 0.0);
        _initializeControllers(); // This will re-create controllers with new dimensions
        _jacobiResult = null;
        _gaussSeidelResult = null;
        _errorMessage = '';
        _diagonalDominanceMessage = '';
      });
    }
  }

  void _updateSystemFromControllers() {
    _initialMatrixA = List.generate(
      _matrixSize,
      (i) => List.generate(
        _matrixSize,
        (j) => double.tryParse(_matrixAControllers[i][j].text) ?? 0.0,
      ),
    );
    _initialVectorF = List.generate(
      _matrixSize,
      (i) => double.tryParse(_vectorFControllers[i].text) ?? 0.0,
    );
    _initialApproximationX0 = List.generate(
      _matrixSize,
      (i) => double.tryParse(_initialApproxControllers[i].text) ?? 0.0,
    );
    _tolerance = double.tryParse(_toleranceController.text) ?? 0.001;
    _maxIterations = int.tryParse(_maxIterationsController.text) ?? 100;
  }

  void _runMethods() {
    FocusScope.of(context).unfocus(); // Dismiss keyboard
    _updateSystemFromControllers();

    setState(() {
      _errorMessage = '';
      _jacobiResult = null;
      _gaussSeidelResult = null;
      _diagonalDominanceMessage = '';
    });

    try {
      bool isDominant = checkDiagonalDominance(_initialMatrixA);
      setState(() {
        _diagonalDominanceMessage = isDominant
            ? "Матрица A диагонально доминирующая"
            : "Матрица A не диагонально доминирующая схождение не гарантировано!";
      });
      
      // Run Jacobi
      _jacobiResult = jacobiMethod(
        A: _initialMatrixA,
        f: _initialVectorF,
        initialApproximation: _initialApproximationX0,
        tolerance: _tolerance,
        maxIterations: _maxIterations,
      );

      // Run Gauss-Seidel
      _gaussSeidelResult = gaussSeidelMethod(
        A: _initialMatrixA,
        f: _initialVectorF,
        initialApproximation: _initialApproximationX0,
        tolerance: _tolerance,
        maxIterations: _maxIterations,
      );

    } catch (e) {
      setState(() {
        _errorMessage = "Error: ${e.toString()}";
      });
    }
    setState(() {}); // Ensure UI updates
  }

  @override
  void dispose() {
    _matrixAControllers.forEach((row) => row.forEach((controller) => controller.dispose()));
    _vectorFControllers.forEach((controller) => controller.dispose());
    _initialApproxControllers.forEach((controller) => controller.dispose());
    _toleranceController.dispose();
    _maxIterationsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('System: Ax = f', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 10),

            TextField(
              decoration: const InputDecoration(
                labelText: 'Размер матрицы (n x n для A)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              controller: TextEditingController(text: _matrixSize.toString()),
               onSubmitted: _updateMatrixSize, // Update on submit
               onChanged: (value) { // Tentative update for matrix size input
                 final newSize = int.tryParse(value);
                 if (newSize == null || newSize <= 0) {
                    // Maybe show a small validation message or just don't update
                    return; 
                 }
                 if (newSize != _matrixSize) {
                    // Debounce or confirm before resizing to avoid performance issues on every keystroke
                    // For now, let's keep it onSubmitted, or use a button to confirm size change
                 }
               },
            ),
            const SizedBox(height: 16),

            Text('Матрица A:', style: Theme.of(context).textTheme.titleMedium),
            if (_matrixAControllers.isNotEmpty)
              Table(
                border: TableBorder.all(color: Colors.grey),
                children: List.generate(_matrixSize, (i) {
                  return TableRow(
                    children: List.generate(_matrixSize, (j) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: TextField(
                          controller: _matrixAControllers[i][j],
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true, signed: true),
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(hintText: 'A[${i + 1}][${j + 1}]'),
                        ),
                      );
                    }),
                  );
                }),
              ),
            const SizedBox(height: 16),

            Text('Вектор значений f:', style: Theme.of(context).textTheme.titleMedium),
            if (_vectorFControllers.isNotEmpty)
              Table(
                children: List.generate(_matrixSize, (i) {
                  return TableRow(children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                      child: TextField(
                        controller: _vectorFControllers[i],
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true, signed: true),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(hintText: 'f[${i + 1}]'),
                      ),
                    ),
                  ]);
                }),
              ),
            const SizedBox(height: 16),

            Text('Первоначальное приближение x(0):', style: Theme.of(context).textTheme.titleMedium),
             if (_initialApproxControllers.isNotEmpty)
              Table(
                children: List.generate(_matrixSize, (i) {
                  return TableRow(children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                      child: TextField(
                        controller: _initialApproxControllers[i],
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true, signed: true),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(hintText: 'x0[${i + 1}]'),
                      ),
                    ),
                  ]);
                }),
              ),
            const SizedBox(height: 16),

            TextField(
              controller: _toleranceController,
              decoration: const InputDecoration(
                  labelText: 'Точность (e.g., 0.001)',
                  border: OutlineInputBorder()),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _maxIterationsController,
              decoration: const InputDecoration(
                  labelText: 'Ограничение итераций (e.g., 100)',
                  border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _runMethods,
              child: const Text('--Решить--'),
            ),
            const SizedBox(height: 20),

            if (_diagonalDominanceMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  _diagonalDominanceMessage,
                  style: TextStyle(
                      color: _diagonalDominanceMessage.contains("не диагонально")
                          ? Colors.orange
                          : Colors.green,
                      fontWeight: FontWeight.bold),
                ),
              ),

            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
            
            if (_jacobiResult != null && _jacobiResult!['error'] == null)
              _buildResultSection("Метод Якоби", _jacobiResult!),
            if (_jacobiResult != null && _jacobiResult!['error'] != null)
              _buildErrorSection("Jacobi Method Error", _jacobiResult!['error']),


            if (_gaussSeidelResult != null && _gaussSeidelResult!['error'] == null)
              _buildResultSection("Гаусс-Зейдель Метод", _gaussSeidelResult!),
            if (_gaussSeidelResult != null && _gaussSeidelResult!['error'] != null)
              _buildErrorSection("Gauss-Seidel Method Error", _gaussSeidelResult!['error']),

          ],
        ),
      ),
    );
  }

  Widget _buildErrorSection(String title, String error) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.red)),
          const SizedBox(height: 5),
          Text(error, style: const TextStyle(color: Colors.redAccent)),
          const Divider(),
        ],     ),
    );
  }

  Widget _buildResultSection(String methodName, Map<String, dynamic> result) {
    List<double> solution = result['solution'] as List<double>;
    int iterations = result['iterations'] as int;
    double achievedTolerance = result['achievedTolerance'] as double;
    double timeMs = result['executionTimeMs'] as double;
    List<String> steps = result['steps'] as List<String>;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(methodName, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text('Приближенное решение (x):', style: Theme.of(context).textTheme.titleMedium),
          ...solution.asMap().entries.map(
                (entry) => Text('x[${entry.key}] = ${entry.value.toStringAsFixed(5)}'),
              ),
          const SizedBox(height: 8),
          Text('Итерации: $iterations'),
          Text('Достигнута точность: ${achievedTolerance.toStringAsExponential(3)}'),
          Text('Время выполнения: ${timeMs.toStringAsFixed(3)} ms'),
          const SizedBox(height: 8),
          Text('Шаги:', style: Theme.of(context).textTheme.titleMedium),
          Container(
            height: 150, // Constrain height for scrollability
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Scrollbar(
              thumbVisibility: true,
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: steps.length,
                itemBuilder: (context, index) => Text(steps[index], style: const TextStyle(fontFamily: 'monospace')),
              ),
            ),
          ),
          const Divider(height: 20, thickness: 1),
        ],
      ),
    );
  }
}
