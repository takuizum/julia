# Zygote pkg
using Pkg; Pkg.add("Zygote") # master

using Zygote, StatsFuns

function icc2pl(θ, α, β)
    p = zeros(length(θ))
    for i in 1:length(θ)
        p[i] = logistic(α*(θ[i]-β))
    end
    p
end
icc2pl([-4:.1:4;], 1.0, 0.0)
using Plots
plot([-4:.1:4;], icc2pl([-4:.1:4;], 1, 0))

icc2pl'(1.0, 1.0, 0.0)
gradient(θ -> icc2pl(θ, 1, 0), 0 # ????
gradient(x -> 3x^2 + 2x + 1, 5)
