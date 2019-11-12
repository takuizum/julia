using PyPlot
theta = collect(-4:0.1:4)
icc = 1.0 ./(1.0 .+ exp.(-2.0.*(theta .- 0.0)))

plot(theta, icc)
