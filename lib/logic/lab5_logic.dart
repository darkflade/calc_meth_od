import 'dart:math';
import 'lab3_logic.dart';

// ---- Подынтегральная функция ----
double f(double x) {
  if (x == 0) return 0; // Предотвращение деления на ноль
  return x * sin(1 / pow(x, 3));
}

// ---- Метод Симпсона ----
double simpson(double a, double b, int n) {
  if (n % 2 != 0) n++; // Симпсон требует чётное n
  double h = (b - a) / n;
  double sum1 = 0.0;
  double sum2 = 0.0;

  for (int i = 1; i < n; i += 2) {
    sum1 += f(a + i * h);
  }
  for (int i = 2; i < n; i += 2) {
    sum2 += f(a + i * h);
  }

  return h / 3.0 * (f(a) + 4.0 * sum1 + 2.0 * sum2 + f(b));
}

// ---- Симпсон + правило Рунге ----
Map<String, dynamic> simpsonWithRunge(double a, double b, double eps) {
  int n = 4;
  double i1 = simpson(a, b, n);
  double i2 = simpson(a, b, n * 2);
  const p = 4; // порядок точности Симпсона

  while ((i2 - i1).abs() / (pow(2, p) - 1) > eps) {
    n *= 2;
    if (n > 10000) { // Предохранитель от бесконечного цикла
      throw Exception("Достигнут предел итераций для Симпсона.");
    }
    i1 = i2;
    i2 = simpson(a, b, n * 2);
  }

  final finalN = n * 2;
  print('Симпсон: I = $i2, n = $finalN');
  return {'value': i2, 'n': finalN};
}


// ---- Гаусс-Лежандр квадратура ----
// ----      Лежандр лежит       ----
class DynamicGaussLegendre {
  static Map<String, double> legendrePolynomial(int n, double x) {
    if (n == 0) return {'p': 1.0, 'dp': 0.0};
    if (n == 1) return {'p': x, 'dp': 1.0};

    double p_prev = 1.0; // P_{n-2}
    double p_curr = x;   // P_{n-1}

    for (int i = 2; i <= n; i++) {
      double p_next = ((2 * i - 1) * x * p_curr - (i - 1) * p_prev) / i;
      p_prev = p_curr;
      p_curr = p_next;
    }

    double dp = n * (x * p_curr - p_prev) / (x * x - 1);

    return {'p': p_curr, 'dp': dp};
  }

  static Map<String, List<double>> calculateNodesAndWeights(int n, double epsilon) {
    final nodes = List<double>.filled(n, 0);
    final weights = List<double>.filled(n, 0);

    print("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    print("      Генерация узлов и весов Гаусса-Лежандра (n=$n)");
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    // Ищем корни. Они симметричны относительно нуля.
    for (int i = 0; i < (n + 1) / 2; i++) {


      double guess = cos(pi * (i + 1 - 0.25) / (n + 0.5));
      MathFunction p_n = (double x) => legendrePolynomial(n, x)['p']!;
      MathFunction dp_n = (double x) => legendrePolynomial(n, x)['dp']!;

      print("\n Узел #${i + 1}: начальное приближение x₀ = ${guess.toStringAsFixed(6)}");

      final lab3 = Lab3Logic(f: p_n, df: dp_n);
      final result = lab3.newtonMethodFor5(guess, epsilon);
      final root = result['root']!;

      nodes[i] = root;
      nodes[n - 1 - i] = -root;

      final dp_val = legendrePolynomial(n, root)['dp']!;
      final weight = 2 / ((1 - root * root) * dp_val * dp_val);

      weights[i] = weight;
      weights[n - 1 - i] = weight; // Симметричный вес

      print(" Корень найден: x = ${root.toStringAsFixed(12)}");
      print("️  Вес: w = ${weight.toStringAsFixed(12)}");
    }

    print("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    print("Итоговая таблица узлов и весов:");
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    print("  №   |        x_i         |        w_i");
    print("  ------------------------------------");
    for (int i = 0; i < n; i++) {
      print("  ${i + 1}   | ${nodes[i].toStringAsFixed(10).padLeft(15)} | ${weights[i].toStringAsFixed(12).padLeft(15)}");
    }
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n");

    return {'nodes': nodes, 'weights': weights};
  }
}

double dynamicGaussQuadrature(double a, double b, int n, double epsilon) {
  final data = DynamicGaussLegendre.calculateNodesAndWeights(n, epsilon);
  final xs = data['nodes']!;
  final ws = data['weights']!;
  double sum = 0.0;

  for (int i = 0; i < xs.length; i++) {
    double t = xs[i];
    double x = (b - a) / 2 * t + (a + b) / 2;
    sum += ws[i] * f(x);
  }

  return (b - a) / 2 * sum;
}

// ---- Тест: 3 последовательные квадратуры Гаусса ----
String gaussTest(double a, double b, int nStart, double eps) {
  if (nStart < 2) {
    return 'Ошибка: Начальное n для Гаусса должно быть от 2.';
  }

  printLegendreFormula(0);

  final results = <int, double>{};
  final buffer = StringBuffer();

  for (int k = 0; k < 3; k++) {
    int n = nStart + k;
    final I = dynamicGaussQuadrature(a, b, n, eps);
    results[n] = I;
    final line = 'Гаусс (n=$n): I = ${I.toStringAsFixed(8)}';
    print(line);
    buffer.writeln(line);

    if (k > 0) {
      final prevN = n-1;
      if (results.containsKey(prevN)) {
        final prevI = results[prevN]!;
        final diffLine = '   |I_{$n} - I_{$prevN}| = ${(I - prevI).abs().toStringAsFixed(8)}';
        print(diffLine);
        buffer.writeln(diffLine);
      }
    }
  }
  return buffer.toString();
}


void printLegendreFormula(int n) {
  print("\n📘 Формула полинома Лежандра Pₙ(x):");
  print("    Pₙ(x) = (1 / 2ⁿ·n!) · dⁿ/dxⁿ[(x² - 1)ⁿ]");
  print("    (Производная по x берётся $n раз)\n");
}

// ---- Метод Монте-Карло ----
class MonteCarloLogic {
  final int n1;
  final int n2;
  final int n3;

  MonteCarloLogic({this.n1 = 10000, this.n2 = 1000000, this.n3 = 100000000});

  double _monteCarloIntegral(int N) {
    final rand = Random();
    double sumFx = 0.0;

    for (int i = 0; i < N; i++) {
      // Интеграл ∫∫∫ x dz dy dx
      // по области x∈[1,2], y∈[2,4], z∈[1,5]
      double x = 1 + rand.nextDouble();
      sumFx += x;
    }

    double avgFx = sumFx / N;
    double volume = (2 - 1) * (4 - 2) * (5 - 1); // объем области = 8
    return avgFx * volume;
  }

  String run() {
    final buffer = StringBuffer();
    double I1 = _monteCarloIntegral(n1);
    double I2 = _monteCarloIntegral(n2);
    double I3 = _monteCarloIntegral(n3);

    buffer.writeln('I₁ (N=${n1.toStringAsExponential(0)}): ${I1.toStringAsFixed(8)}');
    buffer.writeln('I₂ (N=${n2.toStringAsExponential(0)}): ${I2.toStringAsFixed(8)}');
    buffer.writeln('I₃ (N=${n3.toStringAsExponential(0)}): ${I3.toStringAsFixed(8)}');
    buffer.writeln('\nМодули разностей:');
    buffer.writeln('|I₂ - I₁| = ${(I2 - I1).abs().toStringAsFixed(8)}');
    buffer.writeln('|I₃ - I₂| = ${(I3 - I2).abs().toStringAsFixed(8)}');
    buffer.writeln('\nТочное значение: 12.0');

    return buffer.toString();
  }
}
