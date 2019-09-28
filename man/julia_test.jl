using Pkg
Pkg.add("Plots")

using Plots
gr()
plot(randn(100,2))

pi

println(3* randn(100, 3))

x = [1,2,3,4,5,6,7,8,9,10]
x[1]

plot([x, x*2, 3x])

x::Float32
println(x * 2)

random = rand(10)
x * random

plot(x*rand(10))


z = 2
typeof(z)
z * x
z

x = rand(1)

x * z
