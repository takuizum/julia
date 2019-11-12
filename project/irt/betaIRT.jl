# Beta IRT model
using StatsFuns, Distributions

# response function
mutable struct brm2
    α::Vector{Float64}
    β::Vector{Float64}
end

mutable struct brm1
    τ::Vector{Float64}
    β::Vector{Float64}
end

test = brm2(rand(10), rand(11))
test.α[1] = 0
test
test.β[1] = "hoge"

mutable struct MissingIndicator
    u::Vector{Int64}
    g::Int64
end

# BRM2
function irf(para::brm2, θ, y, Mis::MissingIndicator)
    shape1 = shape2 = zeros(eltype(y))
    @show shape1 = @. exp(para.α[Mis.u]*(θ - para.β[Mis.u])/2)
    shape2 = @. exp(para.α[Mis.u]*(para.β[Mis.u] - θ)/2)
    y = y[Mis.u]
    p = @. Distributions.pdf(Distributions.Beta(shape1, shape2), y)
    return p
end
# BRM1
function irf(para::brm1, θ::Float64, y::Vector{Float64}, Mis::MissingIndicator)
    @. shape1 = exp((θ - para.β[Mis.u] + para.τ[Mis.u])/2)
    @. shape2 = exp((para.β[Mis.u] - θ + para.τ[Mis.u])/2)
    @. p = Distributions.pdf(Distributions.Beta(shape1, shape2), y[Mis.u])
    return p
end

using Plots
irf(brm2([1.2, 1.0], [0.0, 1.0]), 0.0, [0.5, 0.2], MissingIndicator([1, 1],1))
irf(brm2([1.2], [0.0]), [-4:.1:4;], [0.5], MissingIndicator([1],1))
plot([-4:.1:4], )

# Log pdf
function logirf(para::brm2, θ::Float64, y::Vector{Float64}, Mis::MissingIndicator)
    @. shape1 = exp(para.α[Mis.u]*(θ - para.β[Mis.u])/2)
    @. shape2 = exp(para.α[Mis.u]*(para.β[Mis.u] - θ)/2)
    @. p = Distributions.logpdf(Distributions.Beta(shape1, shape2), y[Mis.u])
    return p
end

function logirf(para::brm1, θ::Float64, y::Vector{Float64}, Mis::MissingIndicator)
    @. shape1 = exp((θ - para.β[Mis.u] + para.τ[Mis.u])/2)
    @. shape2 = exp((para.β[Mis.u] - θ + para.τ[Mis.u])/2)
    @. p = Distributions.pdf(Distributions.Beta(shape1, shape2), y[Mis.u])
end

# marginal likelihood
function mloglik(para::brm2, θ::Vector{Float64}, y::Matrix{Float64}, Mis::Vector{MissingIndicator})
