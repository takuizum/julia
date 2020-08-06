using Plots


# annotate!
plotly()
plot(sin)
annotate!(0, sin(0), text("■", :white, 30))
annotate!(0, sin(0), text("0"))

plotly()
plot(sin)
annotate!(0, sin(0), text("■■", :white, 30))
annotate!(0, sin(0), text("0.0"))

x = range(-4, 4, length = 101)
x_mis = convert(Vector{Union{Float64, Missing}}, x)
x_mis[50:51] .= missing
y_mis = sin.(x_mis)
plot(x, y_mis)
annotate!(0, sin(0), text("0.0"))
