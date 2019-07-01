using PyPlot
using Plots
gr()
theta = collect(-4:0.1:4)
icc = 1.0 ./(1.0 .+ exp.(-2.0.*(theta .- 0.0)))

Plots.gr()
Plots.plot(theta, icc)
PyPlot.plot(theta, icc)


using Distributions, Random, StatsFuns, Plots #$ Distributions は初回に限りPkg.addが必要。
θ = rand(Normal(), 5000)
α = rand(LogNormal(), 30)
β = rand(Normal(-1, 1), 30)
typeof(θ)

function icc2pl(θ::Float64, α::Float64, β::Float64)::Float64
    x::Float64 = α * (θ - β)
    p::Float64 = StatsFuns.logistic(x)
    p
end
icc2pl(1.0, 1.0, 2.0)
icc2pl([1.0, 2.0, 3.0], 1.0, 0.0)

theta = collect(-4:0.1:4)
icc = zeros(length(theta))
for i in 1:length(theta)
    icc[i] = icc2pl(theta[i], 1.0, 0.0)
end
plot(theta, icc)

struct simgenClass2
    resp::Array{Int64,2}
    θ::Array{Float64,1}
    α::Array{Float64,1}
    β::Array{Float64,1}
end

function resgen_bin(N::Int, J::Int)
    θ = rand(Normal(), N)
    α = rand(LogNormal(), J)
    β = rand(Normal(-1, 1), J)
    resp = zeros(Int64, length(θ), length(α))
    for i in 1:length(θ)
        for j in 1:length(α)
            resp[i, j] = ifelse(rand() > icc2pl(θ[i], α[j], β[j]), 0, 1)
        end
    end
    simgenClass2(resp, θ, α, β)
end

N = 50_000
J = 50
@time resp = resgen_bin(N, J)
resp[2]

struct EstepClass2
    resp::Array{Int64,2}
    θ::Array{Float64,1}
    α::Array{Float64,1}
    β::Array{Float64,1}
    Gim::Array{Float64,2}
    Lim::Array{Float64,2}
end

function Estep(N::Int, J::Int, M::Int)
    by = (4-(-4))/M
    xq = collect(-4:by:4)
    aq = pdf.(Normal(), xq) ./ sum(pdf.(Normal(), xq))
    L = zeros(N, length(xq))
    Gim = zeros(N, length(xq))
    # sim data gen
    resp = resgen_bin(N, J)
    x = resp.resp
    α = resp.α
    β = resp.β
    for m in 1:length(xq)
        println("NOW...", m)
        for i in 1:N
            Li = zeros(J)
            # Li = ones(1)
            for j in 1:J
                #p = icc2pl(xq[m], α[j], β[j])
                #Li .*= p^x[i, j] * (1-p)^(1-x[i, j]) # 61.214906 seconds (866.97 M allocations: 15.413 GiB, 3.05% gc time)
                Li[j] = ifelse(x[i, j] == 1, icc2pl(xq[m], α[j], β[j]), 1 - icc2pl(xq[m], α[j], β[j]))
            end
            L[i, m] = prod(Li)
            # L[i, m] = Li[1]
            Gim[i,m] = L[i,m] * aq[m]
        end
        if(m == length(xq))
            for i in 1:N
                Gim[i,m] = Gim[i,m]/sum(Gim[i,:])
            end
        end
    end
    EstepClass2(x, θ, α, β, Gim, L)
end

Estep(50000, 50, 30)
