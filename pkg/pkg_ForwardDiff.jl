# ForwardDiff

using ForwardDiff, StatsFuns

function icc2pl(θ, α, β)
    p = zeros(length(θ))
    for i in 1:length(θ)
        p[i] = logistic(α*(θ[i]-β))
    end
    p
end

θ = [-4: .1: 4;]

gicc = θ -> ForwardDiff.gradient(icc2pl(θ, 1.0, 1.0))
gicc(θ)
