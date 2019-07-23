using Distributions, Plots # Gadfly

d = rand(1000) + rand(1000) + rand(1000)
d = []
histogram(d, colour = 3, alpha = 0.2)

plt = Array{Plots.Plot{Plots.GRBackend}, 2}(undef, 3, 3)
d = rand(1000)
for i in 1:3
    for j in 1:3
        histogram!(d, colour = i+j, alpha = 0.5) # なんだかloopがうまくいかない。
        global d += rand(1000)
    end
end
Gadfly.plot(d, Geom.histogram)
g = histogram(d)
gridstack()
