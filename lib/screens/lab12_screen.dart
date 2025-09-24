// lib/screens/lab12_screen.dart
import 'package:flutter/material.dart';
import '../logic/lab12_logic.dart'; // Assuming your logic file is here

class Lab12Screen extends StatefulWidget {
  const Lab12Screen({super.key, required this.title});

  final String title;

  @override
  State<Lab12Screen> createState() => _Lab12ScreenState();
}class _Lab12ScreenState extends State<Lab12Screen> {
  // Your provided initial matrix A and vector d
  List<List<double>> _initialMatrixA = [
    [2, -1, 0, 0, 0],
    [-3, 8, -1, 0, 0],
    [0, -5, 12, 2, 0],
    [0, 0, -6, 18, -4],
    [0, 0, 0, -5, 10],
  ];
  List<double> _initialVectorD = [-25, 72, -69, -156, 20];

  List<double>? _solutionsX;
  String _errorMessage = '';

  // For dynamic input
  late int _matrixSize;
  late List<List<TextEditingController>> _matrixAControllers;
  late List<TextEditingController> _vectorDControllers;

  @override
  void initState() {
    super.initState();
    _matrixSize = _initialMatrixA.length;
    _initializeControllers();
    // Optionally run with initial values
    // _runThomasAlgorithm();
  }

  void _initializeControllers() {
    _matrixAControllers = List.generate(
      _matrixSize,
          (i) => List.generate(
        _matrixSize,
            (j) {
          double val = 0.0;
          if (i < _initialMatrixA.length && j < _initialMatrixA[i].length) {
            val = _initialMatrixA[i][j];
          }
          // For tridiagonal, pre-fill non-tridiagonal as 0 and make them read-only if desired
          // For simplicity here, we allow editing all, but logic will only use tridiagonal parts.
          return TextEditingController(text: val.toString());
        },
      ),
    );

    _vectorDControllers = List.generate(
      _matrixSize,
          (i) {
        double val = 0.0;
        if (i < _initialVectorD.length) {
          val = _initialVectorD[i];
        }
        return TextEditingController(text: val.toString());
      },
    );
    // Update state to rebuild UI with new controllers
    if (mounted) {
      setState(() {});
    }
  }

  void _updateMatrixSize(String value) {
    final size = int.tryParse(value);
    if (size != null && size > 0) {
      setState(() {
        _matrixSize = size;
        // Reset initial matrices to empty or sensible defaults for new size
        _initialMatrixA = List.generate(_matrixSize, (i) => List.generate(_matrixSize, (j) => (i == j ? 1.0 : (i-j).abs() == 1 ? 0.5 : 0.0) ));
        _initialVectorD = List.filled(_matrixSize, 0.0);
        _initializeControllers();
        _solutionsX = null;
        _errorMessage = '';
      });
    }
  }

  void _updateSystemFromControllers() {
    List<List<double>> newMatrixA = List.generate(
      _matrixSize,
          (i) => List.generate(
        _matrixSize,
            (j) => double.tryParse(_matrixAControllers[i][j].text) ?? 0.0,
      ),
    );
    List<double> newVectorD = List.generate(
      _matrixSize,
          (i) => double.tryParse(_vectorDControllers[i].text) ?? 0.0,
    );
    setState(() {
      _initialMatrixA = newMatrixA;
      _initialVectorD = newVectorD;
    });
  }

  void _runThomasAlgorithm() {
    FocusScope.of(context).unfocus(); // Dismiss keyboard
    _updateSystemFromControllers(); // Get latest values from TextFields

    setState(() {
      _errorMessage = '';
      _solutionsX = null;
    });

    try {
      // Parse the full matrix A and vector d into a, b, c, d diagonals
      Map<String, List<double>> parsedSystem =
      parseTridiagonalSystem(_initialMatrixA, _initialVectorD);

      List<double> a = parsedSystem['a']!;
      List<double> b = parsedSystem['b']!;
      List<double> c = parsedSystem['c']!;
      List<double> d = parsedSystem['d']!;

      _solutionsX = thomasAlgorithm(a, b, c, d);
    } catch (e) {
      setState(() {
        _errorMessage = "Error: ${e.toString()}";
      });
    }
    setState(() {}); // Ensure UI updates
  }

  @override
  void dispose() {
    for (var rowControllers in _matrixAControllers) {
      for (var controller in rowControllers) {
        controller.dispose();
      }
    }
    for (var controller in _vectorDControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thomas Algorithm (Tridiagonal)'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('System: Ax = d', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 10),

            // Input for matrix size
            TextField(
              decoration: const InputDecoration(
                labelText: 'Matrix Size (n x n for A)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              controller: TextEditingController(text: _matrixSize.toString()),
              onSubmitted: _updateMatrixSize, // Or onChanged if you prefer live updates
            ),
            const SizedBox(height: 16),

            // --- Matrix A Input ---
            Text('Coefficient Matrix A (Tridiagonal):', style: Theme.of(context).textTheme.titleMedium),
            if (_matrixAControllers.isNotEmpty)
              Table(
                border: TableBorder.all(color: Colors.grey),
                defaultColumnWidth: const IntrinsicColumnWidth(flex: 1),
                children: List.generate(_matrixSize, (i) {
                  return TableRow(
                    children: List.generate(_matrixSize, (j) {
                      bool isTridiagonalElement = (i == j) || (i - j).abs() == 1;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: TextField(
                          controller: _matrixAControllers[i][j],
                          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                          textAlign: TextAlign.center,
                          style: TextStyle(backgroundColor: isTridiagonalElement ? Colors.transparent : Colors.grey[300]),
                          readOnly: !isTridiagonalElement, // Make non-tridiagonal elements read-only
                          decoration: InputDecoration(
                            hintText: 'A[${i+1}][${j+1}]',
                            fillColor: isTridiagonalElement ? null : Colors.grey[200],
                            filled: !isTridiagonalElement,
                          ),
                        ),
                      );
                    }),
                  );
                }),
              ),
            const SizedBox(height: 16),

            // --- Vector d Input ---
            Text('Right-Hand Side Vector d:', style: Theme.of(context).textTheme.titleMedium),
            if (_vectorDControllers.isNotEmpty)
              Table(
                children: List.generate(_matrixSize, (i) {
                  return TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                          child: TextField(
                            controller: _vectorDControllers[i],
                            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(hintText: 'd[${i+1}]'),
                          ),
                        ),
                      ]
                  );
                }),
              ),
            const SizedBox(height: 20),

            Center(
              child: ElevatedButton(
                onPressed: _runThomasAlgorithm,
                child: const Text('Solve with Thomas Algorithm'),
              ),
            ),
            const SizedBox(height: 20),

            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),

            if (_solutionsX != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Solutions (x):',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ..._solutionsX!.asMap().entries.map((entry) {
                    return Text(
                        'x[${entry.key + 1}] = ${entry.value.toStringAsFixed(4)}');
                  }).toList(),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
