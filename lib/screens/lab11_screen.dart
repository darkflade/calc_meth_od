import 'package:flutter/material.dart';
import '../logic/lab11_logic.dart';

class Lab11Screen extends StatefulWidget {
  const Lab11Screen({super.key, required this.title});

  final String title;

  @override
  State<Lab11Screen> createState() => _Lab11ScreenState();
}

class _Lab11ScreenState extends State<Lab11Screen> {

  List<List<double>> _initialMatrix = [
    [5, 0, 1, 11],
    [2, 6, -2, 8],
    [-3, 2, 10, 6],
  ];



  List<List<List<double>>> _matrixSteps = [];
  List<double>? _solutions;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _runGaussianElimination();
  }

  void _runGaussianElimination() {
    setState(() {
      _errorMessage = '';
      _matrixSteps = [];
      _solutions = null;
    });
    try {
      // Make a deep copy to avoid modifying the original _initialMatrix
      // if you plan to re-run with the same initial matrix.
      List<List<double>> matrixCopy =
      _initialMatrix.map((row) => List<double>.from(row)).toList();

      _matrixSteps = gaussianEliminationWithPivoting(matrixCopy);

      // If the matrix was augmented and you want to solve for variables:
      if (_matrixSteps.isNotEmpty &&
          _matrixSteps.last.isNotEmpty &&
          _matrixSteps.last[0].length == _matrixSteps.last.length + 1) { // Check if it looks like an augmented matrix
        _solutions = backSubstitution(_matrixSteps.last);
      }

    } catch (e) {
      setState(() {
        _errorMessage = "Error: ${e.toString()}";
      });
    }
  }

  int _rows = 3;
  int _cols = 4;
  List<List<TextEditingController>> _controllers = [];

  void _initializeControllers() {
    _controllers = List.generate(
      _rows,
          (i) => List.generate(
        _cols,
            (j) {
          double initialValue = 0.0;
          if (i < _initialMatrix.length && j < _initialMatrix[i].length) {
            initialValue = _initialMatrix[i][j];
          }
          return TextEditingController(text: initialValue.toString());
        },
      ),
    );
  }

  void _updateMatrixFromControllers() {
    List<List<double>> newMatrix = List.generate(
      _rows,
          (i) => List.generate(
        _cols,
            (j) => double.tryParse(_controllers[i][j].text) ?? 0.0,
      ),
    );
    setState(() {
      _initialMatrix = newMatrix;
      _runGaussianElimination();
    });
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize controllers here if _rows or _cols might change based on external factors
    // or if you want to reset them when the widget is rebuilt with different parameters.
    // For this example, initState is fine, but if _rows/_cols were constructor args,
    // didChangeDependencies would be more appropriate for re-initialization.
    if (_controllers.isEmpty || _controllers.length != _rows || (_controllers.isNotEmpty && _controllers[0].length != _cols)) {
      _initializeControllers();
    }
  }


  @override
  void dispose() {
    for (var rowControllers in _controllers) {
      for (var controller in rowControllers) {
        controller.dispose();
      }
    }
    super.dispose();
  }
  // --- End of UI for dynamic matrix input ---


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gaussian Elimination Steps'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // --- Input for matrix dimensions (Optional) ---
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Rows (for A in Ax=b)'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final r = int.tryParse(value);
                      if (r != null && r > 0) {
                        setState(() {
                          _rows = r;
                          // If solving Ax=b, columns of A is also r, plus 1 for b
                          _cols = r + 1;
                          _initializeControllers();
                        });
                      }
                    },
                    controller: TextEditingController(text: _rows.toString()),
                  ),
                ),
                const SizedBox(width: 10),
                Text("x $_cols matrix (A|b)"), // Display effective columns
              ],
            ),
            const SizedBox(height: 10),
            // --- End of Input for matrix dimensions ---

            // --- Matrix Input Fields ---
            if (_controllers.isNotEmpty)
              const Text('Enter Matrix (A|b):', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            if (_controllers.isNotEmpty)
              Table(
                border: TableBorder.all(color: Colors.grey),
                children: List.generate(_rows, (i) {
                  return TableRow(
                    children: List.generate(_cols, (j) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: TextField(
                          controller: _controllers[i][j],
                          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            hintText: 'A[${i+1}][${j+1}]${j == _cols -1 ? " (b${i+1})" : ""}',
                          ),
                        ),
                      );
                    }),
                  );
                }),
              ),
            ElevatedButton(
              onPressed: () {
                FocusScope.of(context).unfocus(); // Dismiss keyboard
                _updateMatrixFromControllers();
              },
              child: const Text('Solve / Show Steps'),
            ),
            const SizedBox(height: 20),
            // --- End of Matrix Input Fields ---

            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
            if (_matrixSteps.isEmpty && _errorMessage.isEmpty)
              const Center(child: CircularProgressIndicator())
            else if (_matrixSteps.isNotEmpty)
              ..._matrixSteps.asMap().entries.map((entry) {
                int stepIndex = entry.key;
                List<List<double>> matrix = entry.value;
                String title;
                if (stepIndex == 0) {
                  title = 'Initial Matrix:';
                } else if (stepIndex == _matrixSteps.length -1 && _solutions != null) {
                  title = 'Step ${stepIndex}: Upper Triangular Form (Ready for Back Substitution)';
                }
                else {
                  // A more sophisticated way to describe the step could be implemented
                  // by tracking operations in lab1_logic.dart
                  title = 'Step $stepIndex:';
                }
                return _buildMatrixDisplay(title, matrix);
              }).toList(),

            if (_solutions != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Solutions (Back Substitution):',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    ..._solutions!.asMap().entries.map((entry) {
                      return Text('x${entry.key + 1} = ${entry.value.toStringAsFixed(4)}');
                    }).toList(),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatrixDisplay(String title, List<List<double>> matrix) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          if (matrix.isEmpty)
            const Text('Matrix is empty.')
          else
            Table(
              border: TableBorder.all(color: Colors.blueGrey),
              defaultColumnWidth: const IntrinsicColumnWidth(), // Adjust column width to content
              children: matrix.map((row) {
                return TableRow(
                  children: row.map((cell) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        cell.toStringAsFixed(2), // Format to 2 decimal places
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontSize: 15),
                      ),
                    );
                  }).toList(),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}