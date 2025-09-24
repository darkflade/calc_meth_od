// lib/logic/lab12_logic.dart

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
