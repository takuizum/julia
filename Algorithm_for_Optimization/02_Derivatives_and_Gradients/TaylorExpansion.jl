using TaylorSeries
using Plots

f(x) = cos(x)
plot(f)
# Approximation order 1 about x
t1 = Taylor1(Float64, 1)
f(t1 + 1)
plot()


g(x) = x^3 - 10
plot(g)
