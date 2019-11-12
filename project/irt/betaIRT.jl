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
function irf(para::brm2, θ::Float64, y::Vector{Float64}, Mis::MissingIndicator)
    # shape1 = shape2 = zeros(eltype(y), length(y))
    shape1 = @. exp(para.α[Mis.u]*(θ - para.β[Mis.u])/2)
    shape2 = @. exp(para.α[Mis.u]*(para.β[Mis.u] - θ)/2)
    p = @. Distributions.pdf(Distributions.Beta(shape1, shape2), y[Mis.u])
    return p
end
# BRM2(for plotting)
function irf(para::brm2, θ::Vector{Float64}, y::Float64)
    # shape1 = shape2 = zeros(eltype(y), length(y))
    shape1 = @. exp(para.α*(θ - para.β)/2)
    shape2 = @. exp(para.α*(para.β - θ)/2)
    p = @. Distributions.pdf(Distributions.Beta(shape1, shape2), y)
    return p
end
# BRM1
function irf(para::brm1, θ::Float64, y::Vector{Float64}, Mis::MissingIndicator)
    # shape1 = shape2 = zeros(eltype(y), length(y))
    shape1 = @. exp((θ - para.β[Mis.u] + para.τ[Mis.u])/2)
    shape2 = @. exp((para.β[Mis.u] - θ + para.τ[Mis.u])/2)
    p = @. Distributions.pdf(Distributions.Beta(shape1, shape2), y[Mis.u])
    return p
end

# multiple item response in a subject
irf(brm2([1.2, 2.0], [0.0, 2.0]), 1.0, [0.5, 0.2], MissingIndicator([1, 2],1))
using Plots
plot([-4:.1:4], irf(brm2([1.2], [2.0]), [-4:.1:4;], 0.5))

# Log pdf
function logirf(para::brm2, θ::Float64, y::Vector{Float64}, Mis::MissingIndicator)
    shape1 = @. exp(para.α[Mis.u]*(θ - para.β[Mis.u])/2)
    shape2 = @. exp(para.α[Mis.u]*(para.β[Mis.u] - θ)/2)
    p = @. Distributions.logpdf(Distributions.Beta(shape1, shape2), y[Mis.u])
    return p
end

function logirf(para::brm1, θ::Float64, y::Vector{Float64}, Mis::MissingIndicator)
    shape1 = @. exp((θ - para.β[Mis.u] + para.τ[Mis.u])/2)
    shape2 = @. exp((para.β[Mis.u] - θ + para.τ[Mis.u])/2)
    p = @. Distributions.pdf(Distributions.Beta(shape1, shape2), y[Mis.u])
    return p
end

# marginal likelihood
mutable struct mloglik_
    lnP_im::Matrix{Float64}
    lnP::Float64
end

function mloglik(para::brm2, θ::Vector{Float64}, W::Vector{Float64}, y::Matrix{Float64}, Mis::Vector{MissingIndicator})
    N, J = size(y)
    M = size(W, 1)
    lnP = zero(Float64, 1)
    for m in 1:M
        for i in 1:N
            lnP_im = logirf(para, θ, W, y[i,:], Mis[i])
            lnP += sum(lnP_im)
        end
    end
    return mloglik_(lnP_im, lnP)
end
