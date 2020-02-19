

f(x) = 3x + 2x^2

using Plots
plot(f)
plot(sin)

# See https://github.com/JuliaLang/julia/blob/master/base/mathconstants.jl
using Base.MathConstants
φ
golden

function fibonacci_search(f, a, b, n; ϵ = .01)
    #
    println("Start searching local minima.")
    ϕ = φ
    s = (1-√5) / (1+√5)
    ρ = 1 / (ϕ*(1-s^(n+1))/(1-s^n))
    d = ρ*b + (1-ρ)*a
    yd = f(d)
    plt_range = (0.5a, 1.5b)
    init_range = (a, b)
    anim = @animate for i in 1 : n-1
        if i == n-1
            c = ϵ*a + (1-ϵ)*d
        else
            c = ρ*a + (1-ρ)*b
        end
        yc = f(c)
        if yc < yd
            b, d, yd = d, c, yc
        else
            a, b = b, c
        end
        ρ = 1 / (ϕ*(1-s^(n-i+1))/(1-s^(n-i)))
        if 100 % i == 0
            println(a < b ? (a, b) : (b, a))
        end
        plt_range = a < b ? (a, b) : (b, a)
        plt = plot(f, xlims = plt_range, legend = :topleft, label = "Iter:$(i)")
        plt = vline!([a, b], lc = :black, label = "")
        glb_plt = plot(f, xlims = init_range, legend = :topleft, label = "")
        glb_plt = vline!([a, b], lc = :black, label = "")
        plot(plt, glb_plt, layout = (1,2))
    end
    gif(anim, "03_Bracketing/FibonacciSearch.gif", fps=10)
    return a < b ? (a, b) : (b, a)
end

fibonacci_search(sin, -4, -2, 10)
fibonacci_search(f, -4, 4, 20)
