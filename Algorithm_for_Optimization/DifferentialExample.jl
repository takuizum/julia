using StatsFuns
# SymEngineの利用には管理者権限が必要。
# FOR Mac user -> sudo chown -R username /Users/username/.julia/

# Symbolic Differentiation
using SymEngine
# Define variables
# Use @vars of symbols()
@vars x; typeof(x)
f = x^2 + x/2 - sin(x)/x; typeof(f)
# Differentiation
diff(f, x)
# Expand
a,b = symbols("a b")
expand(a + 2(b+2)^2 + 2a + 3(a+1))
# Substitution
subs(a^2+(b-2)^2, a=>2)

@vars θ
f2 = 1 / (1+exp(-a*(θ-b)))
diff(f2, a)

# Numerical Differentiation (Single variables)
diff_forward(f, x; h=sqrt(eps(Float64))) = (f(x+h) - f(x))/h
diff_central(f, x; h=cbrt(eps(Float64))) = (f(x+h/2) - f(x-h/2))/h
diff_backward(f, x; h=sqrt(eps(Float64))) = (f(x) - f(x-h))/h

using Plots
plot(sin)
# 1/2周りでの近似
f3 = sin(x)
diff(f3, x); cos(1/2) # Analytic differential
diff_forward(sin, 1/2)
diff_backward(sin, 1/2)
diff_central(sin, 1/2)
# Complex method
# im : imaginary unit (part)
# imag : Return imaginary parg of f
diff_complex(f, x; h = sqrt(eps(Float64))) = imag(f(x + h*im))/ h
diff_complex(sin, 1/2)
# comparison
function CompDiffMethod(H)
    z = zeros(Float64, length(H), 4)
    for (i,h) in enumerate(H)
        z[i,1] = abs(cos(1/2) - diff_forward(sin, 1/2; h = h))
        z[i,2] = abs(cos(1/2) - diff_backward(sin, 1/2; h = h))
        z[i,3] = abs(cos(1/2) - diff_central(sin, 1/2; h = h))
        z[i,4] = abs(cos(1/2) - diff_complex(sin, 1/2; h = h))
    end
    return z .+ 1e-18
end

StepSize = [eval(Meta.parse("10^-$x")) for x in 18:-0.1:0]
comp = CompDiffMethod(StepSize)
plot(StepSize, comp, xscale = :log10, yscale = :log10, label = ["Forward" "backward" "Central" "Complex"])

# Diff image plot

derivplot = let
    plot(sin, xlim = (0, 1), ylim = (0, 1), label = "sin", legend = :topleft)
    scatter!([1/2], [sin(1/2)], label = "")
    plot!(-2:.1:2, x -> cos(1/2)*(x - 1/2) + sin(1/2), label = "Analytic")
end
savefig(derivplot, "Algorithm_for_Optimization/derivexample.png")

StepSize2 = [eval(Meta.parse("10^-$x")) for x in 0:5:20]
anim = @animate for i in StepSize2
    plot(sin, xlim = (0, 1), ylim = (0, 1), label = "sin", legend = :topleft)
    scatter!([1/2], [sin(1/2)], label = "")
    plot!(0:.02:1, x -> cos(1/2)*(x - 1/2) + sin(1/2), label = "Analytic")
    plot!(0:.02:1, x -> diff_forward(sin, 1/2; h = i) * (x - 1/2) + sin(1/2), label = "ForwardDiff")
end
gif(anim, "Algorithm_for_Optimization/DerivSim.gif", fps=2)