class DataPoint {
  final double x;
  final double y;
  DataPoint(this.x, this.y);
}

class InterpolationLogic {
  final List<DataPoint> data;

  InterpolationLogic(this.data) {
    // Проверяем, что в таблице нет дубликатов по X, это критично для всех методов.
    final xValues = data.map((p) => p.x).toList();
    if (xValues.toSet().length != xValues.length) {
      throw ArgumentError("Значения X в таблице не должны повторяться.");
    }
  }

  // 1. Интерполяционный полином Лагранжа
  double lagrange(double x) {
    double sum = 0;
    for (int i = 0; i < data.length; i++) {
      double product = data[i].y;
      for (int j = 0; j < data.length; j++) {
        if (i != j) {
          product *= (x - data[j].x) / (data[i].x - data[j].x);
        }
      }
      sum += product;
    }
    return sum;
  }

  // 2. Схема Эйткена
  Map<String, dynamic> aitken(double x, double epsilon) {
    int n = data.length;
    List<double> p = data.map((point) => point.y).toList();

    for (int k = 1; k < n; k++) {
      List<double> nextP = List.filled(n, 0);
      for (int i = 0; i < n - k; i++) {
        nextP[i] = ((x - data[i+k].x) * p[i] - (x - data[i].x) * p[i+1]) / (data[i].x - data[i+k].x);
      }
      p = nextP;

      if ((p[0] - p[1]).abs() < epsilon) {
        return {'value': p[0], 'iterations': k};
      }
    }
    return {'value': p[0], 'iterations': n-1};
  }

  // 3. Интерполяция с конечными разностями (Ньютон)
  List<List<double>> calculateFiniteDifferences() {
    if (data.length < 2) return [];

    // Проверяем, что узлы равноотстоящие
    double h = data[1].x - data[0].x;
    for (int i = 1; i < data.length - 1; i++) {
      if ((data[i+1].x - data[i].x - h).abs() > 1e-9) {
        throw ArgumentError("Для метода Ньютона узлы (значения X) должны быть равноотстоящими.");
      }
    }

    List<List<double>> differences = [];
    List<double> currentDifferences = data.map((p) => p.y).toList();

    for (int i = 0; i < data.length - 1; i++) {
      List<double> nextDifferences = [];
      for (int j = 0; j < currentDifferences.length - 1; j++) {
        nextDifferences.add(currentDifferences[j+1] - currentDifferences[j]);
      }
      differences.add(nextDifferences);
      currentDifferences = nextDifferences;
    }

    return differences;
  }

  // Метод для вычисления значения по формуле Ньютона
  double newton(double x, List<List<double>> diffTable) {
    if (data.isEmpty) return double.nan;

    double h = data[1].x - data[0].x;
    double t = (x - data[0].x) / h;

    double result = data[0].y;
    double tProduct = 1.0;
    int factorial = 1;

    for (int i = 0; i < diffTable.length; i++) {
      tProduct *= (t - i);
      factorial *= (i + 1);

      if (diffTable[i].isEmpty) break; // Таблица может закончиться

      result += (tProduct * diffTable[i][0]) / factorial;
    }

    return result;
  }
}