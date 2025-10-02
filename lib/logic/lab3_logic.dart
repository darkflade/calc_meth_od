import 'dart:math';

typedef MathFunction = double Function(double);

class Lab3Logic {
  final MathFunction f;
  final MathFunction? df;

  Lab3Logic({required this.f, this.df});

  // Метод Ньютона
  Map<String, double> newtonMethod(double initialGuess, double epsilon) {
    if (df == null) {
      throw StateError("Производная (df) не была предоставлена для метода Ньютона.");
    }

    double x = initialGuess;
    int iterations = 0;
    double prevX;

    print("--- Начало работы метода Ньютона ---");
    do {
      prevX = x;
      double fx = f(prevX);
      double dfx = df!(prevX);

      if (dfx.abs() < 1e-12) {
        throw ArgumentError("Производная в точке $prevX близка к нулю. Метод не может продолжаться.");
      }

      x = prevX - fx / dfx;
      iterations++;
      print('Итерация ${iterations}: x = ${x.toStringAsFixed(8)}');

    } while ((x - prevX).abs() > epsilon && iterations < 1000);
    print("--- Конец работы ---");

    return {'root': x, 'iterations': iterations.toDouble()};
  }

  // Метод половинного деления (для одного корня)
  Map<String, double> bisectionMethod(double a, double b, double epsilon) {
    // Проверка пограничного корня
    if (f(a).abs() < epsilon) return {'root': a, 'iterations': 0};
    if (f(b).abs() < epsilon) return {'root': b, 'iterations': 0};

    if (f(a) * f(b) > 0) {
      throw ArgumentError("Значения f(a) и f(b) должны иметь разные знаки.");
    }

    double c = a;
    int iterations = 0;

    print("--- Поиск корня на интервале [${a}, ${b}] ---");
    while ((b - a).abs() > epsilon && iterations < 1000) {
      c = (a + b) / 2;
      iterations++;
      print('Итерация ${iterations}: c = ${c.toStringAsFixed(8)}');

      double fc = f(c);

      if (f(c).abs() < 1e-12) {
        break;
      }

      if ((fc > 0 && f(a) > 0) || (fc < 0 && f(a) < 0)) {
        a = c;
      } else {
        b = c;
      }

    }
    print("--- Корень найден ---");
    return {'root': c, 'iterations': iterations.toDouble()};
  }

  List<Map<String, double>> findAllRootsBisection(double start, double end, double step, double epsilon) {
    final List<Map<String, double>> roots = [];
    double currentPos = start;

    print("--- Начало поиска всех корней на интервале [${start}, ${end}] с шагом ${step} ---");
    while (currentPos < end) {
      double nextPos = currentPos + step;
      if (nextPos > end) nextPos = end;

      if (f(currentPos) * f(nextPos) <= 0) {
        try {
          final result = bisectionMethod(currentPos, nextPos, epsilon);
          if (f(result['root']!).abs() < epsilon) {
            if (roots.every((r) =>
            (r['root']! - result['root']!).abs() > epsilon * 10)) {
              roots.add(result);
            }
          } else {
            roots.add(result);
            print("Отфильтрован ложный корень: ${result['root']} т.к. f(x) = ${f(result['root']!)}");
          }
        } catch (e) {
          print("Ошибка при поиске корня на интервале [${currentPos}, ${nextPos}]: $e");
        }
      }
      currentPos = nextPos;
    }
    print("--- Поиск всех корней завершен ---");
    return roots;
  }
}