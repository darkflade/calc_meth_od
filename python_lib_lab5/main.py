from mpmath import mp, sin, quad, quadts, quadgl, quadts

# Точность 50 знаков
mp.dps = 50

# f(x) = x * sin(1/x^3)
def f(x):
    return x * sin(1 / x**3)

a, b = mp.mpf(1), mp.mpf(2)

# --- Метод Симпсона ---
simpson_res = quad(f, [a, b])

# --- Метод Гаусса-Лежандра ---
gauss_res = quadts(f, [a, b])

print(f"Симпсон (quad):  {simpson_res}")
print(f"Гаусс (quadts):  {gauss_res}")
print( "Эталон        :  0.47700710215784439527606573611131026296")
print(f"Разность      :        {abs(simpson_res - gauss_res)}")
