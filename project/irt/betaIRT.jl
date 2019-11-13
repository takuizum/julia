# Beta IRT model
using StatsFuns, Distributions

# response function
mutable struct brm1
    τ::Vector{Float64}
    β::Vector{Float64}
end

mutable struct brm2
    α::Vector{Float64}
    β::Vector{Float64}
end

mutable struct brm3
    α::Vector{Float64}
    β::Vector{Float64}
    τ::Vector{Float64}
end
# plot output struct
mutable struct brm_plot
    p::Vector{Float64}
    shape1::Float64
    shape2::Float64
end

test = brm2(rand(10), rand(11))
test.α[1] = 0
test
test.β[1] = "hoge"

mutable struct MissingIndicator
    u::Vector{Int64}
    g::Int64
end

# BRM1
function irf(para::brm1, θ::Float64, y::Vector{Float64}, Mis::MissingIndicator)
    # shape1 = shape2 = zeros(eltype(y), length(y))
    shape1 = @. exp((θ - para.β[Mis.u] + para.τ[Mis.u])/2)
    shape2 = @. exp((para.β[Mis.u] - θ + para.τ[Mis.u])/2)
    p = @. Distributions.pdf.(Distributions.Beta(shape1, shape2), y[Mis.u])
    return p
end
# BRM1(for θ base plotting)
function irf(para::brm1, θ::Vector{Float64}, y::Float64)
    # shape1 = shape2 = zeros(eltype(y), length(y))
    shape1 = @. exp((θ - para.β + para.τ)/2)
    shape2 = @. exp((para.β - θ + para.τ)/2)
    # @show shape1 shape2
    p = @. Distributions.pdf.(Distributions.Beta(shape1, shape2), y)
    return brm_plot(p, shape1[1], shape2[1])
end
# BRM1(for y base plotting)
function irf(para::brm1, θ::Float64, y::Vector{Float64})
    # shape1 = shape2 = zeros(eltype(y), length(y))
    shape1 = @. exp((θ - para.β + para.τ)/2)
    shape2 = @. exp((para.β - θ + para.τ)/2)
    # @show shape1 shape2
    p = @. Distributions.pdf.(Distributions.Beta(shape1, shape2), y)
    return brm_plot(p, shape1[1], shape2[1])
end

# BRM2
function irf(para::brm2, θ::Float64, y::Vector{Float64}, Mis::MissingIndicator)
    # shape1 = shape2 = zeros(eltype(y), length(y))
    shape1 = @. exp(para.α[Mis.u]*(θ - para.β[Mis.u])/2)
    shape2 = @. exp(para.α[Mis.u]*(para.β[Mis.u] - θ)/2)
    p = @. Distributions.pdf.(Distributions.Beta(shape1, shape2), y[Mis.u])
    return p
end
# BRM2(for θ base plotting)
function irf(para::brm2, θ::Vector{Float64}, y::Float64)
    # shape1 = shape2 = zeros(eltype(y), length(y))
    shape1 = @. exp(para.α*(θ - para.β)/2)
    shape2 = @. exp(para.α*(para.β - θ)/2)
    # @show shape1 shape2
    p = @. Distributions.pdf.(Distributions.Beta(shape1, shape2), y)
    return brm_plot(p, shape1[1], shape2[1])
end
# BRM2(for y base plotting)
function irf(para::brm2, θ::Float64, y::Vector{Float64})
    # shape1 = shape2 = zeros(eltype(y), length(y))
    shape1 = @. exp(para.α*(θ - para.β)/2)
    shape2 = @. exp(para.α*(para.β - θ)/2)
    # @show shape1 shape2
    p = @. Distributions.pdf.(Distributions.Beta(shape1, shape2), y)
    return brm_plot(p, shape1[1], shape2[1])
end

# BRM3
function irf(para::brm3, θ::Float64, y::Vector{Float64}, Mis::MissingIndicator)
    # shape1 = shape2 = zeros(eltype(y), length(y))
    shape1 = @. exp(para.α[Mis.u]*(θ - para.β[Mis.u] + para.τ[Mis.u])/2)
    shape2 = @. exp(para.α[Mis.u]*(para.β[Mis.u] - θ + para.τ[Mis.u])/2)
    p = @. Distributions.pdf.(Distributions.Beta(shape1, shape2), y[Mis.u])
    return p
end
# BRM3(for θ base plotting)
function irf(para::brm3, θ::Vector{Float64}, y::Float64)
    # shape1 = shape2 = zeros(eltype(y), length(y))
    shape1 = @. exp(para.α*(θ - para.β + para.τ)/2)
    shape2 = @. exp(para.α*(para.β - θ + para.τ)/2)
    # @show shape1 shape2
    p = @. Distributions.pdf.(Distributions.Beta(shape1, shape2), y)
    return brm_plot(p, shape1[1], shape2[1])
end
# BRM3(for y base plotting)
function irf(para::brm3, θ::Float64, y::Vector{Float64})
    # shape1 = shape2 = zeros(eltype(y), length(y))
    shape1 = @. exp(para.α*(θ - para.β + para.τ)/2)
    shape2 = @. exp(para.α*(para.β - θ + para.τ)/2)
    # @show shape1 shape2
    p = @. Distributions.pdf.(Distributions.Beta(shape1, shape2), y)
    return brm_plot(p, shape1[1], shape2[1])
end

# multiple item response in a subject
irf(brm2([1.2, 2.0], [0.0, 2.0]), 1.0, [0.5, 0.2], MissingIndicator([1, 2],1))

using Plots, Interact, CSSUtil, ORCA, Printf
# ICC
function Response_prob_plot(mod::DataType)
    gr()
    if fieldnames(mod) == (:α, :β, :τ)
        @manipulate for α in -0:0.001:4, β in -4:.001:4, τ in -4:.001:4, y in 0:.001:1
            res = irf(mod([α], [β], [τ]), [-4:.1:4;], y)
            plot([-4:.1:4], res.p,
                 label = "ICC", xlabel = "theta", ylabel = "Probability")
            annotate!(0, 0, "Model is $(string(mod))\nshape1 = $(@sprintf("%.3f",res.shape1)),shape2 = $(@sprintf("%.3f", res.shape2))")
            ylims!((0,Inf))
        end
    elseif fieldnames(mod) == (:τ, :β)
        @manipulate for τ in -4:0.001:4, β in -4:.001:4, y in 0:.001:1
            res = irf(mod([τ], [β]), [-4:.1:4;], y)
            plot([-4:.1:4], res.p,
                 label = "ICC", xlabel = "theta", ylabel = "Probability")
            annotate!(0, 0, "Model is $(string(mod))\nshape1 = $(@sprintf("%.3f",res.shape1)),shape2 = $(@sprintf("%.3f", res.shape2))")
            ylims!((0,Inf))
        end
    elseif fieldnames(mod) == (:α, :β)
        @manipulate for α in -0:0.001:4, β in -4:.001:4, y in 0:.001:1
            res = irf(mod([α], [β]), [-4:.1:4;], y)
            plot([-4:.1:4], res.p,
                 label = "ICC", xlabel = "theta", ylabel = "Probability")
            annotate!(0, 0, "Model is $(string(mod))\nshape1 = $(@sprintf("%.3f",res.shape1)),shape2 = $(@sprintf("%.3f", res.shape2))")
            ylims!((0,Inf))
        end
    end
end
function Response_prob_plot()
    gr()
    @manipulate for α in -0:0.001:4, β in -4:.001:4, τ in -4:.001:4, y in 0:.001:1
        res1 = irf(brm1([τ], [β]), [-4:.1:4;], y)
        res2 = irf(brm2([α], [β]), [-4:.1:4;], y)
        res3 = irf(brm3([α], [β], [τ]), [-4:.1:4;], y)
        plot([-4:.1:4], res1.p, label = "BRM1", xlabel = "theta: latent trait", ylabel = "Probability Density")
        plot!([-4:.1:4], res2.p, label = "BRM2")
        plot!([-4:.1:4], res3.p, label = "BRM3")
        ylims!((0,Inf))
    end
end
Response_prob_plot(brm1)
Response_prob_plot(brm2)
Response_prob_plot(brm3)
Response_prob_plot()

# Genarative function
plot([0:.01:1], irf(brm2(fill(1.0, 101), fill(0.0, 101)), 1.0, [0:.01:1;]))
function Generative_plot(mod::DataType)
    gr()
    if fieldnames(mod) == (:α, :β, :τ)
        @manipulate for α in -0:0.001:4, β in -4:.001:4, τ in -4:.001:4, θ in -4.0:.001:4.0
            res = irf(mod([α], [β], [τ]), θ, [0:.01:1;])
            plot([0:.01:1;], res.p,
                 label = "Beta Densityy", xlabel = "y: observed response", ylabel = "Probability")
            annotate!(0.5, 0, "Model is $(string(mod))\nshape1 = $(@sprintf("%.3f",res.shape1)),shape2 = $(@sprintf("%.3f", res.shape2))")
            ylims!((0,Inf))
        end
    elseif fieldnames(mod) == (:τ, :β)
        @manipulate for τ in -4:0.001:4, β in -4:.001:4, θ in -4.0:.001:4.0
            res = irf(mod([τ], [β]), θ, [0:.01:1;])
            plot([0:.01:1;], res.p,
                 label = "Beta Densityy", xlabel = "y: observed response", ylabel = "Probability")
            annotate!(0.5, 0, "Model is $(string(mod))\nshape1 = $(@sprintf("%.3f",res.shape1)),shape2 = $(@sprintf("%.3f", res.shape2))")
            ylims!((0,Inf))
        end
    elseif fieldnames(mod) == (:α, :β)
        @manipulate for α in -2:0.001:2.0, β in -4.0:.001:4.0, θ in -4.0:.001:4.0
            res = irf(mod([α], [β]), θ, [0:.01:1;])
            plot([0:.01:1;], res.p,
                 label = "Beta Densityy", xlabel = "y: observed response", ylabel = "Probability")
            annotate!(0.5, 0, "Model is $(string(mod))\nshape1 = $(@sprintf("%.3f",res.shape1)),shape2 = $(@sprintf("%.3f", res.shape2))")
            ylims!((0,Inf))
        end
    end
end
function Generative_plot()
    gr()
    @manipulate for α in -0:0.001:4, β in -8:.001:8, τ in -8:.001:8, θ in -8:.001:8
        res1 = irf(brm1([τ], [β]), θ, [0:.01:1;])
        res2 = irf(brm2([α], [β]), θ, [0:.01:1;])
        res3 = irf(brm3([α], [β], [τ]), θ, [0:.01:1;])
        plot([0:.01:1;], res1.p, label = "BRM1", xlabel = "y: observed response", ylabel = "Probability Density")
        plot!([0:.01:1;], res2.p, label = "BRM2")
        plot!([0:.01:1;], res3.p, label = "BRM3")
        ylims!((0,Inf))
    end
end

Generative_plot(brm1)
Generative_plot(brm2)
Generative_plot(brm3)
Generative_plot()

# Log pdf
function logirf(para::brm2, θ::Float64, y::Vector{Float64}, Mis::MissingIndicator)
    shape1 = @. exp(para.α[Mis.u]*(θ - para.β[Mis.u])/2)
    shape2 = @. exp(para.α[Mis.u]*(para.β[Mis.u] - θ)/2)
    p = @. Distributions.logpdf.(Distributions.Beta(shape1, shape2), y[Mis.u])
    return p
end

function logirf(para::brm1, θ::Float64, y::Vector{Float64}, Mis::MissingIndicator)
    shape1 = @. exp((θ - para.β[Mis.u] + para.τ[Mis.u])/2)
    shape2 = @. exp((para.β[Mis.u] - θ + para.τ[Mis.u])/2)
    p = @. Distributions.pdf.(Distributions.Beta(shape1, shape2), y[Mis.u])
    return p
end

# marginal likelihood
function mloglik(para, θ::Vector{Float64}, W::Vector{Float64}, y::Matrix{Float64}, Mis::Vector{MissingIndicator})
    N, J = size(y)
    M = size(W, 1)
    lnP = zero(Float64, 1)

    for m in 1:M
        for i in 1:N
            lnP += sum(W[m] .* logirf(para, θ, y[i,:], Mis[i]))
        end
    end
    # return mloglik_(lnP_im, lnP)
    lnP
end

# generate simulation response
b_0 = rand(Normal(0,1), 10)
a_0 = rand(LogNormal(0,1), 10)
θ_0 = rand(Normal(0,1), 500)
function beta_response(para::brm2, θ)
    N = size(θ, 1)
    shape1 = [ exp(para.α[j]*(θ[i] - para.β[j])/2) for i in 1:N, j in 1:length(para.α) ]
    shape2 = [ exp(para.α[j]*(para.β[j] - θ[i])/2) for i in 1:N, j in 1:length(para.α) ]
    N, J = size(shape1)
    data = Matrix{Union{Float64, Missing}}(undef, N, J)
    [ data[i,j] = rand(Beta(shape1[i], shape2[i])) for i in 1:N, j in 1:J]
    data[1, 1] = missing
    data
end

test = beta_response(brm2(a_0, b_0), θ_0)
function mis_ind_gen(data)
    N = size(data, 1)
    mis = [ MissingIndicator(findall(j -> j isa Number, data[i,:]), 1 ) for i in 1:N]
end
test2 = mis_ind_gen(test)

# calc log lik
nodes = [range(-4, 4, length = 31);]
weights = pdf.(Normal(0, 1), nodes) ./ sum(pdf.(Normal(0, 1), nodes))
mloglik(brm2(a_0, b_0), )
# 個人ごとのEAPを計算して，その重みを算出する必要がある
