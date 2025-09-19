// lib/logic/lab_1_logic.dart

/// Performs Gaussian elimination with partial pivoting on a given augmented matrix [A|b].
///
/// The input matrix should represent an augmented system Ax = b.
/// Returns a list of matrices, where each matrix represents a step in the
/// elimination process. The last matrix in the list is the upper triangular form
/// of the augmented system.
///
/// Throws an ArgumentError if the matrix is empty, or if the coefficient part 'A'
/// is not square (i.e., rows != cols - 1).
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

  int n = numRows; // Number of variables, which is number of rows

  for (int i = 0; i < n; i++) {
    // Partial Pivoting: Find the row with the largest absolute value in the current column (within A)
    int maxRow = i;
    for (int k = i + 1; k < n; k++) {
      if ((currentMatrix[k][i]).abs() > (currentMatrix[maxRow][i]).abs()) {        maxRow = k;
      }
    }

    // Swap rows if necessary (entire rows of the augmented matrix)
    if (maxRow != i) {
      List<double> temp = currentMatrix[i];
      currentMatrix[i] = currentMatrix[maxRow];
      currentMatrix[maxRow] = temp;
      steps.add(currentMatrix.map((row) => List<double>.from(row)).toList());
    }

    // Make all rows below this one 0 in current column
    for (int k = i + 1; k < n; k++) {
      if (currentMatrix[i][i] == 0) {
        // If pivot is zero after pivoting, it implies singularity or dependency.
        // For this example, we'll continue. A robust solution might throw an error
        // or return a specific status.
        continue;
      }
      double factor = currentMatrix[k][i] / currentMatrix[i][i];
      // Apply transformation to all elements in the row, including the augmented part
      for (int j = i; j < numCols; j++) { // Iterate up to numCols (A and b)
        currentMatrix[k][j] -= factor * currentMatrix[i][j];
      }
    }
    // Add a copy of the current state of the matrix to steps
    // Ensure that only if there were actual changes (pivoting or elimination), a new step is added
    // This check can be more sophisticated, but for now, we add after each column operation.
    if (i < n -1 || maxRow != i ) { // Add step if pivoting happened or if it's not the last elimination pass
      steps.add(currentMatrix.map((row) => List<double>.from(row)).toList());
    } else if (steps.last.toString() != currentMatrix.toString()) { // Add if different from last step
      steps.add(currentMatrix.map((row) => List<double>.from(row)).toList());
    }
  }
  // Ensure the final matrix is always added if it's different from the last recorded step
  if (steps.isEmpty || steps.last.toString() != currentMatrix.toString()) {
    steps.add(currentMatrix.map((row) => List<double>.from(row)).toList());
  }


  return steps;
}

/// Solves a system of linear equations from an upper triangular augmented matrix
/// using back substitution.
///
/// `augmentedMatrix` is the upper triangular matrix [U|c] obtained from Gaussian elimination.
///
/// Returns a list of doubles representing the solution [x1, x2, ..., xn].
/// Throws an Exception if the matrix is singular or no unique solution exists.
List<double> backSubstitution(List<List<double>> upperTriangularAugmentedMatrix) {
  int n = upperTriangularAugmentedMatrix.length; // Number of equations/variables
  if (n == 0) return [];
  if (upperTriangularAugmentedMatrix[0].length != n + 1) {
    throw ArgumentError("Augmented matrix for back substitution should have n rows and n+1 columns.");
  }

  List<double> solutions = List<double>.filled(n, 0);

  for (int i = n - 1; i >= 0; i--) {
    if (upperTriangularAugmentedMatrix[i][i] == 0) {
      // Check if it leads to contradiction (0 * x_i = non_zero) or infinite solutions (0 * x_i = 0)
      if (upperTriangularAugmentedMatrix[i][n] != 0) { // n is the index of the last column (constants)
        throw Exception("System has no solution (contradiction found).");
      } else {
        throw Exception("System has infinitely many solutions (a free variable exists).");
        // Or handle by returning a special indicator / allowing parameterization of solution
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
