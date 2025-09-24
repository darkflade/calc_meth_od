// lib/logic/lab_1_logic.dart

List<List<List<double>>> gaussianEliminationWithPivoting(List<List<double>> augmentedMatrix) {
  if (augmentedMatrix.isEmpty) {
    throw ArgumentError("Matrix cannot be empty.");
  }

  int numRows = augmentedMatrix.length;
  if (numRows == 0) {
    throw ArgumentError("Matrix cannot be empty.");
  }
  int numCols = augmentedMatrix[0].length;

  if (numCols != numRows + 1) {
    throw ArgumentError(
        "Augmented matrix should have one more column than rows (for [A|b]). "
            "Current dimensions: $numRows rows, $numCols cols. "
            "This function expects the coefficient matrix A to be square.");
  }

  List<List<List<double>>> steps = [];
  List<List<double>> currentMatrix = augmentedMatrix.map((row) => List<double>.from(row)).toList();
  steps.add(currentMatrix.map((row) => List<double>.from(row)).toList()); // Initial matrix

  int n = numRows;

  for (int i = 0; i < n; i++) {
    int maxRow = i;
    for (int k = i + 1; k < n; k++) {
      if ((currentMatrix[k][i]).abs() > (currentMatrix[maxRow][i]).abs()) {        maxRow = k;
      }
    }

    if (maxRow != i) {
      List<double> temp = currentMatrix[i];
      currentMatrix[i] = currentMatrix[maxRow];
      currentMatrix[maxRow] = temp;
      steps.add(currentMatrix.map((row) => List<double>.from(row)).toList());
    }

    for (int k = i + 1; k < n; k++) {
      if (currentMatrix[i][i] == 0) {
        continue;
      }
      double factor = currentMatrix[k][i] / currentMatrix[i][i];
      for (int j = i; j < numCols; j++) {
        currentMatrix[k][j] -= factor * currentMatrix[i][j];
      }
    }
    if (i < n -1 || maxRow != i ) {
      steps.add(currentMatrix.map((row) => List<double>.from(row)).toList());
    } else if (steps.last.toString() != currentMatrix.toString()) {
      steps.add(currentMatrix.map((row) => List<double>.from(row)).toList());
    }
  }
  if (steps.isEmpty || steps.last.toString() != currentMatrix.toString()) {
    steps.add(currentMatrix.map((row) => List<double>.from(row)).toList());
  }


  return steps;
}

List<double> backSubstitution(List<List<double>> upperTriangularAugmentedMatrix) {
  int n = upperTriangularAugmentedMatrix.length;
  if (n == 0) return [];
  if (upperTriangularAugmentedMatrix[0].length != n + 1) {
    throw ArgumentError("Augmented matrix for back substitution should have n rows and n+1 columns.");
  }

  List<double> solutions = List<double>.filled(n, 0);

  for (int i = n - 1; i >= 0; i--) {
    if (upperTriangularAugmentedMatrix[i][i] == 0) {
      if (upperTriangularAugmentedMatrix[i][n] != 0) {
        throw Exception("System has no solution (contradiction found).");
      } else {
        throw Exception("System has infinitely many solutions (a free variable exists).");
      }
    }
    double sum = 0;
    for (int j = i + 1; j < n; j++) {
      sum += upperTriangularAugmentedMatrix[i][j] * solutions[j];
    }
    solutions[i] = (upperTriangularAugmentedMatrix[i][n] - sum) / upperTriangularAugmentedMatrix[i][i];
  }
  return solutions;
}
