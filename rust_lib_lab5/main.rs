use scirs2_integrate::{gaussian::gauss_kronrod21, quad::simpson};
//use std::f64::consts::PI;

fn main() {

    // Отрезок интегрирования
    // [1;2]
    let a:f64 =  1.0;
    let b:f64 = 2.0;

    // Определяем функцию для интегрирования
    // f(x) = x * sin(1/x^3)
    let f = |x: f64| x * (1.0 / x.powi(3)).sin();

    // Вычисляем интеграл на интервале [1, 2]
    let result_simpson = simpson(&f, a, b, 10000);
    let result_gaussian = gauss_kronrod21(&f, a, b);


    // Выводим результаты
    println!("Результат Симпсона: {}", result_simpson.unwrap()); // 0.4770071012423852
    println!("Результат Гаусса  : {}", result_gaussian.0) // 0.4770071021452016
    // 0.47700710215784439527606573611131026296

}
