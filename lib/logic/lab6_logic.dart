
import 'dart:math';

class PointData {
  final double x;
  final double yApprox;
  final double yExact;
  final double error;

  PointData({
    required this.x,
    required this.yApprox,
    required this.yExact,
  }) : error = (yApprox - yExact).abs();

  @override
  String toString() {
    return 'x: ${x.toStringAsFixed(2)}, y_approx: ${yApprox.toStringAsFixed(6)}, y_exact: ${yExact.toStringAsFixed(6)}, error: ${error.toStringAsFixed(8)}';
  }
}

// Result class to hold the points and the method name
class MethodResult {
  final String methodName;
  final String scheme;
  final List<PointData> points;

  MethodResult({required this.methodName, required this.scheme, required this.points});
}

class CauchyProblemSolver {
  // Cauchy Problem parameters
  final double x0 = 1.0;
  final double y0 = 1.0;
  final double xEnd = 1.5;

  // Function
  double _f(double x, double y) => y * y + y;

  // Solve Cauchy for Comparison
  double _exactY(double x) {
    final ex = exp(x);
    return -ex / (ex - 2 * e);
  }

  // --- 1. Euler's Method ---
  MethodResult euler(double h) {
    final points = <PointData>[];
    double currentX = x0;
    double currentY = y0;

    points.add(PointData(x: currentX, yApprox: currentY, yExact: _exactY(currentX)));

    int steps = ((xEnd - x0) / h).round();
    for (int i = 0; i < steps; i++) {
      currentY += h * _f(currentX, currentY);
      currentX += h;
      points.add(PointData(x: currentX, yApprox: currentY, yExact: _exactY(currentX)));
    }
    return MethodResult(methodName: 'Euler', scheme: 'y_{n+1} = y_{n} + hf(x_{n}, y_{n})', points: points);
  }

  // --- 2. Symmetrical Scheme (Explicit Midpoint) ---
  MethodResult symmetrical(double h) {
    final points = <PointData>[];
    double currentX = x0;
    double currentY = y0;

    points.add(PointData(x: currentX, yApprox: currentY, yExact: _exactY(currentX)));
    
    int steps = ((xEnd - x0) / h).round();
    for (int i = 0; i < steps; i++) {
      double k1 = _f(currentX, currentY);
      double yMid = currentY + h / 2 * k1;
      double xMid = currentX + h / 2;
      currentY += h * _f(xMid, yMid);
      currentX += h;
      points.add(PointData(x: currentX, yApprox: currentY, yExact: _exactY(currentX)));
    }
    return MethodResult(methodName: 'Symmetrical', scheme: 'y_{n+1} = y_{n-1} + 2hf(x_{n}, y_{n})', points: points);
  }

  // --- 3. Runge-Kutta 2nd Order (Heun's Method) ---
  MethodResult rungeKutta2(double h) {
    final points = <PointData>[];
    double currentX = x0;
    double currentY = y0;

    points.add(PointData(x: currentX, yApprox: currentY, yExact: _exactY(currentX)));
    
    int steps = ((xEnd - x0) / h).round();
    for (int i = 0; i < steps; i++) {
      double k1 = _f(currentX, currentY);
      double k2 = _f(currentX + h, currentY + h * k1);
      currentY += h / 2 * (k1 + k2);
      currentX += h;
      points.add(PointData(x: currentX, yApprox: currentY, yExact: _exactY(currentX)));
    }
    return MethodResult(methodName: 'Runge-Kutta 2', scheme: 'y_{n+1} = y_{n} + h/2(k_{1} + k_{2})', points: points);
  }

  // --- 4. Runge-Kutta 4th Order ---
  MethodResult rungeKutta4(double h) {
    final points = <PointData>[];
    double currentX = x0;
    double currentY = y0;

    points.add(PointData(x: currentX, yApprox: currentY, yExact: _exactY(currentX)));
    
    int steps = ((xEnd - x0) / h).round();
    for (int i = 0; i < steps; i++) {
      double k1 = _f(currentX, currentY);
      double k2 = _f(currentX + h / 2, currentY + h / 2 * k1);
      double k3 = _f(currentX + h / 2, currentY + h / 2 * k2);
      double k4 = _f(currentX + h, currentY + h * k3);
      currentY += h / 6 * (k1 + 2 * k2 + 2 * k3 + k4);
      currentX += h;
      points.add(PointData(x: currentX, yApprox: currentY, yExact: _exactY(currentX)));
    }
    return MethodResult(methodName: 'Runge-Kutta 4', scheme: 'y_{n+1} = y_{n} + h/6(k_{1} + 2k_{2} + 2k_{3} + k_{4})', points: points);
  }
  
  // Helper for Adams methods to get starting points
  List<PointData> _getStartingPoints(double h, int count) {
    // Using RK4 for higher accuracy starting values
    final points = <PointData>[];
    double currentX = x0;
    double currentY = y0;

    points.add(PointData(x: currentX, yApprox: currentY, yExact: _exactY(currentX)));
    
    for (int i = 0; i < count - 1; i++) {
      double k1 = _f(currentX, currentY);
      double k2 = _f(currentX + h / 2, currentY + h / 2 * k1);
      double k3 = _f(currentX + h / 2, currentY + h / 2 * k2);
      double k4 = _f(currentX + h, currentY + h * k3);
      currentY += h / 6 * (k1 + 2 * k2 + 2 * k3 + k4);
      currentX += h;
      points.add(PointData(x: currentX, yApprox: currentY, yExact: _exactY(currentX)));
    }
    return points;
  }

  // --- 5. Explicit Adams 3-step ---
  MethodResult adamsExplicit3(double h) {
    final points = _getStartingPoints(h, 3);
    
    int steps = ((xEnd - x0) / h).round();
    for (int i = 2; i < steps; i++) {
      double f_i = _f(points[i].x, points[i].yApprox);
      double f_i_minus_1 = _f(points[i-1].x, points[i-1].yApprox);
      double f_i_minus_2 = _f(points[i-2].x, points[i-2].yApprox);
      
      double nextY = points[i].yApprox + h / 12 * (23 * f_i - 16 * f_i_minus_1 + 5 * f_i_minus_2);
      double nextX = points[i].x + h;
      
      points.add(PointData(x: nextX, yApprox: nextY, yExact: _exactY(nextX)));
    }
    return MethodResult(methodName: 'Adams Explicit 3', scheme: 'y_{n+1} = y_{n} + h/12(23f_{n} - 16f_{n-1} + 5f_{n-2})', points: points);
  }

  // --- 6. Implicit Adams 3-step ---
  MethodResult adamsImplicit3(double h) {
    final points = _getStartingPoints(h, 3);
    
    int steps = ((xEnd - x0) / h).round();
    for (int i = 2; i < steps; i++) {
      double nextX = points[i].x + h;
      
      double f_i = _f(points[i].x, points[i].yApprox);
      double f_i_minus_1 = _f(points[i-1].x, points[i-1].yApprox);
      double f_i_minus_2 = _f(points[i-2].x, points[i-2].yApprox);
      
      // Predictor (Explicit Adams 3-step)
      double y_pred = points[i].yApprox + h / 12 * (23 * f_i - 16 * f_i_minus_1 + 5 * f_i_minus_2);
      
      // Corrector (Implicit Adams 3-step, y_{n+1} = y_n + h/12 * (5f_{n+1} + 8f_n - f_{n-1}))
      double f_pred = _f(nextX, y_pred);
      double nextY = points[i].yApprox + h / 12 * (5 * f_pred + 8 * f_i - f_i_minus_1);
      
      points.add(PointData(x: nextX, yApprox: nextY, yExact: _exactY(nextX)));
    }
    return MethodResult(methodName: 'Adams Implicit 3', scheme: 'y_{n+1} = y_{n} + h/12 * (5f_{n+1} + 8f_{n} - f_{n-1})', points: points);
  }

  // --- Main runner ---
  List<MethodResult> runAll(double h) {
    return [
      euler(h),
      symmetrical(h),
      rungeKutta2(h),
      rungeKutta4(h),
      adamsExplicit3(h),
      adamsImplicit3(h),
    ];
  }
}
