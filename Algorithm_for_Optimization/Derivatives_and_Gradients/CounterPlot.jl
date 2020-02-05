using Plots

f(x₁, x₂) = x₁^2 - x₂^2

z = [f(x₁, x₂) for x₁ = -2:0.1:2, x₂ = -2:0.1:2]
plot(-2:0.1:2, -2:0.1:2, z, seriestype = :heatmap, c = ColorGradient(:plasma))
plot(-2:0.1:2, -2:0.1:2, z, seriestype = :wireframe)

