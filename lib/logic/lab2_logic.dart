import 'dart:math';

// Helper to print matrix for debugging
String _matrixToString(List<List<double>> matrix) {
  return matrix.map((row) => row.map((e) => e.toStringAsFixed(3)).join('\t')).join('\n');
}

// Helper to print vector for debugging
String _vectorToString(List<double> vector, {int precision = 3}) {
  return '[${vector.map((e) => e.toStringAsFixed(precision)).join(', ')}]';
}

// Helper to calculate the infinity norm of a vector (max absolute element)
double _infinityNorm(List<double> vector) {
  if (vector.isEmpty) return 0.0;
  return vector.map((e) => e.abs()).reduce(max);
}

/// Checks if a matrix is strictly diagonally dominant.
/// A matrix A is strictly diagonally dominant if for every row i,
/// the absolute value of the diagonal element A[i][i] is greater than
/// the sum of the absolute values of all other elements in that row.
///
/// Args:
///   A: The matrix (List of Lists of doubles).
///
/// Returns:
///   true if the matrix is strictly diagonally dominant, false otherwise.
bool checkDiagonalDominance(List<List<double>> A) {
  print("--- Checking Diagonal Dominance ---");
  print("Matrix A:\n${_matrixToString(A)}");
  if (A.isEmpty) {
    print("Result: Matrix is empty. Not diagonally dominant.");
    return false;
  }
  for (int i = 0; i < A.length; i++) {
    if (A[i].length != A.length) {
        print("Result: Matrix is not square. Cannot determine dominance.");
        return false; // Not a square matrix
    }
    double diagonalElement = A[i][i].abs();
    double sumOfOthers = 0;
    for (int j = 0; j < A[i].length; j++) {
      if (i != j) {
        sumOfOthers += A[i][j].abs();
      }
    }
    print("Row $i: |${A[i][i].toStringAsFixed(3)}| vs Sum(${A[i].where((e) => A[i].indexOf(e) != i).map((e) => "|${e.toStringAsFixed(3)}|").join(' + ')}) = $sumOfOthers");
    if (diagonalElement <= sumOfOthers) {
      print("Result: Matrix is NOT strictly diagonally dominant at row $i.");
      return false;
    }
  }
  print("Result: Matrix IS strictly diagonally dominant.");
  print("------------------------------------");
  return true;
}

Map<String, dynamic> jacobiMethod({
  required List<List<double>> A,
  required List<double> f,
  required List<double> initialApproximation,
  required double tolerance, // Renamed from accuracy to tolerance for clarity
  required int maxIterations,
}) {
  final stopwatch = Stopwatch()..start();
  print("\n--- Jacobi Method Started ---");
  print("Matrix A:\n${_matrixToString(A)}");
  print("Vector f: ${_vectorToString(f)}");
  print("Initial Approximation x(0): ${_vectorToString(initialApproximation, precision: 5)}");
  print("Tolerance: $tolerance");
  print("Max Iterations: $maxIterations");

  if (!checkDiagonalDominance(A)) {
    print("WARNING: Matrix is not strictly diagonally dominant. Jacobi method may not converge.");
  }

  int n = A.length;
  List<double> x = List<double>.from(initialApproximation);
  List<double> xNext = List<double>.filled(n, 0);
  List<String> stepsLog = [];
  int iterations = 0;
  double achievedTolerance = double.infinity;

  stepsLog.add("Initial x(0): ${_vectorToString(x, precision: 5)}");

  for (iterations = 0; iterations < maxIterations; iterations++) {
    for (int i = 0; i < n; i++) {
      double sumSigma = 0;
      for (int j = 0; j < n; j++) {
        if (i != j) {
          sumSigma += A[i][j] * x[j];
        }
      }
      if (A[i][i] == 0) {
          stopwatch.stop();
          final result = {
            'solution': x,
            'iterations': iterations,
            'achievedTolerance': achievedTolerance,
            'executionTimeMs': stopwatch.elapsedMicroseconds / 1000.0,
            'steps': stepsLog,
            'error': "Division by zero: A[$i][$i] is zero.",
          };
          print("ERROR: Division by zero at A[$i][$i].");
          print("--- Jacobi Method Ended (Error) ---\n");
          return result;
      }
      xNext[i] = (f[i] - sumSigma) / A[i][i];
    }

    List<double> diff = List.generate(n, (k) => xNext[k] - x[k]);
    achievedTolerance = _infinityNorm(diff);
    
    x = List<double>.from(xNext);
    stepsLog.add("Iter ${iterations + 1}: x(${iterations + 1}) = ${_vectorToString(x, precision: 5)}, Achieved Tolerance: ${achievedTolerance.toStringAsExponential(3)}");
    print(stepsLog.last);

    if (achievedTolerance < tolerance) {
      print("Convergence achieved after ${iterations + 1} iterations.");
      break;
    }
  }
   if (iterations == maxIterations && achievedTolerance >= tolerance) {
    print("Warning: Jacobi method did not converge within $maxIterations iterations. Current tolerance: $achievedTolerance");
  }


  stopwatch.stop();
  final result = {
    'solution': x,
    'iterations': iterations + 1 > maxIterations ? maxIterations : iterations +1, // Ensure iterations don't exceed maxIterations if loop completed fully
    'achievedTolerance': achievedTolerance,
    'executionTimeMs': stopwatch.elapsedMicroseconds / 1000.0,
    'steps': stepsLog,
  };
  print("Final Solution x: ${_vectorToString(result['solution'] as List<double>, precision: 5)}");
  print("Iterations: ${result['iterations']}");
  print("Achieved Tolerance: ${result['achievedTolerance']}");
  print("Execution Time: ${result['executionTimeMs']} ms");
  print("--- Jacobi Method Ended ---\n");
  return result;
}


Map<String, dynamic> gaussSeidelMethod({
  required List<List<double>> A,
  required List<double> f,
  required List<double> initialApproximation,
  required double tolerance,
  required int maxIterations,
}) {
  final stopwatch = Stopwatch()..start();
  print("\n--- Gauss-Seidel Method Started ---");
  print("Matrix A:\n${_matrixToString(A)}");
  print("Vector f: ${_vectorToString(f)}");
  print("Initial Approximation x(0): ${_vectorToString(initialApproximation, precision: 5)}");
  print("Tolerance: $tolerance");
  print("Max Iterations: $maxIterations");

  if (!checkDiagonalDominance(A)) {
    print("WARNING: Matrix is not strictly diagonally dominant. Gauss-Seidel method may still converge, but convergence is not guaranteed by this criterion alone.");
  }

  int n = A.length;
  List<double> x = List<double>.from(initialApproximation);
  List<String> stepsLog = [];
  int iterations = 0;
  double achievedTolerance = double.infinity;

  stepsLog.add("Initial x(0): ${_vectorToString(x, precision: 5)}");

  for (iterations = 0; iterations < maxIterations; iterations++) {
    List<double> xPrevious = List<double>.from(x); // Store x from previous iteration for tolerance calculation

    for (int i = 0; i < n; i++) {
      double sumSigma1 = 0; // Sum for terms with x_j^(k+1) (already updated in this iteration)
      for (int j = 0; j < i; j++) {
        sumSigma1 += A[i][j] * x[j];
      }
      double sumSigma2 = 0; // Sum for terms with x_j^(k) (from previous iteration)
      for (int j = i + 1; j < n; j++) {
        sumSigma2 += A[i][j] * xPrevious[j]; // Use x from k-th iteration
      }
      if (A[i][i] == 0) {
          stopwatch.stop();
          final result = {
            'solution': x,
            'iterations': iterations,
            'achievedTolerance': achievedTolerance,
            'executionTimeMs': stopwatch.elapsedMicroseconds / 1000.0,
            'steps': stepsLog,
            'error': "Division by zero: A[$i][$i] is zero.",
          };
          print("ERROR: Division by zero at A[$i][$i].");
          print("--- Gauss-Seidel Method Ended (Error) ---\n");
          return result;
      }
      x[i] = (f[i] - sumSigma1 - sumSigma2) / A[i][i];
    }

    List<double> diff = List.generate(n, (k) => x[k] - xPrevious[k]);
    achievedTolerance = _infinityNorm(diff);

    stepsLog.add("Iter ${iterations + 1}: x(${iterations + 1}) = ${_vectorToString(x, precision: 5)}, Achieved Tolerance: ${achievedTolerance.toStringAsExponential(3)}");
    print(stepsLog.last);

    if (achievedTolerance < tolerance) {
      print("Convergence achieved after ${iterations + 1} iterations.");
      break;
    }
  }
  if (iterations == maxIterations && achievedTolerance >= tolerance) {
    print("Warning: Gauss-Seidel method did not converge within $maxIterations iterations. Current tolerance: $achievedTolerance");
  }

  stopwatch.stop();
  final result = {
    'solution': x,
    'iterations': iterations + 1 > maxIterations ? maxIterations : iterations +1,
    'achievedTolerance': achievedTolerance,
    'executionTimeMs': stopwatch.elapsedMicroseconds / 1000.0,
    'steps': stepsLog,
  };
  print("Final Solution x: ${_vectorToString(result['solution'] as List<double>, precision: 5)}");
  print("Iterations: ${result['iterations']}");
  print("Achieved Tolerance: ${result['achievedTolerance']}");
  print("Execution Time: ${result['executionTimeMs']} ms");
  print("--- Gauss-Seidel Method Ended ---\n");
  return result;
}

// Example of how you might call Thomas Algorithm (keeping it from previous context if needed)
// Or remove if not relevant to Lab 2 specifically.
List<double> thomasAlgorithm(
    List<double> a, List<double> b, List<double> c, List<double> d) {
  int n = b.length;

  if (a.length != n - 1 || c.length != n - 1 || d.length != n) {
    throw ArgumentError(
        "Input array dimensions are inconsistent for Thomas Algorithm. "
            "b and d should have length n. a and c should have length n-1.");
  }
  if (n == 0) {
    print("Thomas Algorithm: n is 0, returning empty list.");
    return [];
  }
  if (n == 1) {
    if (b[0] == 0) throw ArgumentError("Division by zero: b[0] is zero.");
    print("Thomas Algorithm: n is 1, solving directly.");
    print("x[0] = d[0] / b[0] = ${d[0]} / ${b[0]} = ${d[0] / b[0]}");
    return [d[0] / b[0]];
  }

  List<double> cPrime = List<double>.filled(n - 1, 0);
  List<double> dPrime = List<double>.filled(n, 0);
  List<double> x = List<double>.filled(n, 0);

  print("--- Thomas Algorithm Steps ---");
  print("Initial a: $a");
  print("Initial b: $b");
  print("Initial c: $c");
  print("Initial d: $d");
  print("n = $n");
  print("\n--- Forward Elimination ---");

  if (b[0] == 0) throw ArgumentError("Division by zero in forward elimination: b[0] is zero.");
  cPrime[0] = c[0] / b[0];
  dPrime[0] = d[0] / b[0];
  print("Step 0 (Forward):");
  print("  cPrime[0] = c[0] / b[0] = ${c[0]} / ${b[0]} = ${cPrime[0]}");
  print("  dPrime[0] = d[0] / b[0] = ${d[0]} / ${b[0]} = ${dPrime[0]}");
  print("  cPrime: $cPrime");
  print("  dPrime: $dPrime");


  for (int i = 1; i < n; i++) {
    print("\nStep $i (Forward):");
    double denominator = b[i] - a[i - 1] * cPrime[i - 1];
    print("  Denominator = b[$i] - a[${i-1}] * cPrime[${i-1}] = ${b[i]} - ${a[i-1]} * ${cPrime[i-1]} = $denominator");
    if (denominator == 0) {
      throw ArgumentError(
          "Division by zero in forward elimination at index $i. Matrix may be singular.");
    }
    if (i < n - 1) { 
      cPrime[i] = c[i] / denominator;
      print("  cPrime[$i] = c[$i] / Denominator = ${c[i]} / $denominator = ${cPrime[i]}");
    }
    dPrime[i] = (d[i] - a[i - 1] * dPrime[i - 1]) / denominator;
    print("  dPrime[$i] = (d[$i] - a[${i-1}] * dPrime[${i-1}]) / Denominator");
    print("             = (${d[i]} - ${a[i-1]} * ${dPrime[i-1]}) / $denominator = ${dPrime[i]}");
    if (i < n -1) print("  cPrime: $cPrime");
    print("  dPrime: $dPrime");
  }

  print("\n--- Backward Substitution ---");
  x[n - 1] = dPrime[n - 1];
  print("x[${n-1}] = dPrime[${n-1}] = ${x[n-1]}");

  for (int i = n - 2; i >= 0; i--) {
    x[i] = dPrime[i] - cPrime[i] * x[i + 1];
    print("x[$i] = dPrime[$i] - cPrime[$i] * x[${i+1}]");
    print("     = ${dPrime[i]} - ${cPrime[i]} * ${x[i+1]} = ${x[i]}");
  }
  print("\nFinal solution x: $x");
  print("---------------------------\n");

  return x;
}

Map<String, List<double>> parseTridiagonalSystem(
    List<List<double>> matrixA, List<double> vectorD) {
  int n = matrixA.length;
  if (n == 0) {
    throw ArgumentError("Coefficient matrix A cannot be empty.");
  }
  if (matrixA.any((row) => row.length != n)) {
    throw ArgumentError("Coefficient matrix A must be square.");
  }
  if (vectorD.length != n) {
    throw ArgumentError(
        "Dimension of RHS vector d must match the dimension of matrix A.");
  }

  List<double> a = List<double>.filled(n > 1 ? n - 1 : 0, 0);
  List<double> b = List<double>.filled(n, 0);      
  List<double> c = List<double>.filled(n > 1 ? n - 1 : 0, 0); 

  for (int i = 0; i < n; i++) {
    b[i] = matrixA[i][i]; 
    if (i < n - 1) {
      c[i] = matrixA[i][i + 1]; 
    }
    if (i > 0) {
      a[i - 1] = matrixA[i][i - 1]; 
    }
  }
  return {'a': a, 'b': b, 'c': c, 'd': List<double>.from(vectorD)};
}
