using Plot

f(x₁, x₂) = x₁^2 - x₂^2

z = [f(x₁, x₂) for x₁ in -2:.1:2, x₂ in -2:.1:2]
plot(-2:.1:2, -2:.1:2, z, seriestype = :heatmap, c = ColorGradient(:plasma))
plot(-2:.1:2, -2:.1:2, z, seriestype = :wireframe)
