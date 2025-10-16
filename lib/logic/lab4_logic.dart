class DataPoint {
  final double x;
  final double y;
  DataPoint(this.x, this.y);
}

class InterpolationLogic {
  final List<DataPoint> data;

  InterpolationLogic(this.data) {
    final xValues = data.map((p) => p.x).toList();
    if (xValues.toSet().length != xValues.length) {
      throw ArgumentError("Значения X в таблице не должны повторяться.");
    }
  }

  double lagrange(double x) {
    print('\n============================');
    print('Расчет полинома Лагранжа для x = $x');
    print('============================');

    double sum = 0;
    for (int i = 0; i < data.length; i++) {
      double product = data[i].y;
      String productStr = 'L_$i(x) = ${data[i].y}';

      for (int j = 0; j < data.length; j++) {
        if (i != j) {
          product *= (x - data[j].x) / (data[i].x - data[j].x);
          productStr +=
          ' * (x - ${data[j].x}) / (${data[i].x} - ${data[j].x})';
        }
      }

      print('\n  Базисный полином $i:');
      print('   Формула: $productStr');
      print('   Значение L_$i($x) = $product');

      sum += product;
      print('     Текущая сумма = $sum');
    }

    print('\n  Итоговый результат (Лагранж): $sum');
    print('============================\n');
    return sum;
  }

  Map<String, dynamic> aitken(double x, double epsilon) {
    int n = data.length;

    print('\n============================');
    print('  Схема Эйткена для x = $x, ε = $epsilon');
    print('============================');

    List<List<double?>> table = List.generate(n, (_) => List.filled(n, null));

    for (int i = 0; i < n; i++) {
      table[i][0] = data[i].y;
    }

    print('i   x_i      P[i,0]');
    for (int i = 0; i < n; i++) {
      print('${i.toString().padRight(4)}${data[i].x.toStringAsFixed(2).padRight(8)}${table[i][0]!.toStringAsFixed(6)}');
    }
    print('');

    List<double> p = data.map((e) => e.y).toList();

    for (int k = 1; k < n; k++) {
      print('--- Итерация k = $k ---');
      List<double> nextP = List.filled(n, 0);

      for (int i = 0; i < n - k; i++) {
        nextP[i] = ((x - data[i + k].x) * p[i] - (x - data[i].x) * p[i + 1]) /
            (data[i].x - data[i + k].x);

        table[i][k] = nextP[i];
      }

      String header = 'i   x_i      ';
      for (int col = 0; col <= k; col++) header += 'P[i,$col]      ';
      print(header);

      for (int i = 0; i < n; i++) {
        String row = '${i.toString().padRight(4)}${data[i].x.toStringAsFixed(2).padRight(8)}';
        for (int col = 0; col <= k; col++) {
          if (table[i][col] != null) {
            row += table[i][col]!.toStringAsFixed(6).padRight(12);
          } else {
            row += ''.padRight(12);
          }
        }
        print(row);
      }
      print('');

      p = nextP;

      if (k > 1 && (table[0][k]! - table[0][k-1]!).abs() < epsilon) {
        print('✅ Условие останова: |P_0,$k - P_1,$k| = ${(p[0] - p[1]).abs()} < $epsilon');
        print('Результат: ${p[0]} (итераций: $k)');
        print('============================\n');
        return {'value': p[0], 'iterations': k};
      }
    }

    print('Достигнуто максимальное число итераций, результат: ${p[0]}');
    return {'value': p[0], 'iterations': n-1};
  }

  // 3. Интерполяция с конечными разностями (Ньютон)
  List<List<double>> calculateFiniteDifferences() {
    print('\n============================================================================================================================================');
    print('Построение таблицы конечных разностей');
    print('========================================================================================================================================================================');

    if (data.length < 2) {
      print('Недостаточно данных');
      return [];
    }

    double h = data[1].x - data[0].x;
    for (int i = 1; i < data.length - 1; i++) {
      if ((data[i + 1].x - data[i].x - h).abs() > 1e-9) {
        throw ArgumentError("Узлы должны быть равноотстоящими.");
      }
    }
    print('Равноотстоящие узлы: h = $h\n');

    List<List<double>> differences = [];
    List<double> currentDifferences = data.map((p) => p.y).toList();
    print('Δ^0 y: $currentDifferences');

    for (int i = 0; i < data.length - 1; i++) {
      List<double> nextDifferences = [];
      for (int j = 0; j < currentDifferences.length - 1; j++) {
        nextDifferences.add(currentDifferences[j + 1] - currentDifferences[j]);
      }
      if (nextDifferences.isEmpty) break;
      differences.add(nextDifferences);
      currentDifferences = nextDifferences;
    }

    print('Таблица конечных разностей:\n');
    for (int i = 0; i < differences.length; i++) {
      String row = ' ' * (i * 4);
      row += 'Δ^${i + 1}y'.padRight(8);
      for (int j = 0; j < differences[i].length; j++) {
        row += differences[i][j].toStringAsFixed(6).padLeft(12);
      }
      print(row);
    }
    print('========================================================================================================================================================================\n');
    return differences;
  }

  // Метод Ньютона
  double newton(double x, List<List<double>> diffTable) {
    print('\n============================');
    print(' Интерполяция Ньютона для x = $x');
    print('============================');

    if (data.isEmpty) {
      print('Нет данных');
      return double.nan;
    }

    double h = data[1].x - data[0].x;
    double t = (x - data[0].x) / h;
    print('h = $h');
    print('t = (x - x0) / h = ($x - ${data[0].x}) / $h = $t\n');

    double result = data[0].y;
    double tProduct = 1.0;
    int factorial = 1;
    print('Начальное значение: P(x) = y0 = $result');

    print('i |  (t - i)  |   Δ^i y₀  |  tProduct  |  term  |  result ');
    print('-----------------------------------------------');

    for (int i = 0; i < diffTable.length; i++) {
      tProduct *= (t - i);
      factorial *= (i + 1);

      if (diffTable[i].isEmpty) {
        print('Разности закончились на шаге ${i + 1}');
        break;
      }

      double term = (tProduct * diffTable[i][0]) / factorial;
      result += term;

      print('${(i+1).toString().padRight(2)} | '
          '${(t - i).toStringAsFixed(3).padRight(7)} | '
          '${diffTable[i][0].toStringAsFixed(6).padRight(9)} | '
          '${tProduct.toStringAsFixed(6).padRight(9)} | '
          '${term.toStringAsFixed(6).padRight(9)} | '
          '${result.toStringAsFixed(6)}');
    }

    print('\n✅ Итоговый результат (Ньютон): $result');
    print('============================\n');
    return result;
  }
}