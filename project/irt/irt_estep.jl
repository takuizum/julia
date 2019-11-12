using Distributions, Random, StatsFuns, Plots #$ Distributions は初回に限りPkg.addが必要。
θ = rand(Normal(), 5000)
α = rand(LogNormal(), 30)
β = rand(Normal(-1, 1), 30)
typeof(θ)

function icc2pl(θ, α, β)
    x = α * (θ - β)
    p = logistic(x)
    p
end

icc2pl(1.0, 1.0, 2.0)
icc2pl([1.0, 2.0, 3.0], 1.0, 0.0)

theta = collect(-4:0.1:4)
icc = zeros(length(theta),3)
for i in 1:length(theta)
    icc[i,1] = icc2pl(theta[i], 1.0, 0.0) # 標準的な難しさ，識別具合の項目
    icc[i,2] = icc2pl(theta[i], 2.0, 1.5) # 難しくて，識別も良い
    icc[i,3] = icc2pl(theta[i], 0.5, -2.0) # 易しくて，あんまり識別できない
end
plot(theta, icc[:,1], label = "standard", legend=:bottomright)
plot!(theta, icc[:,2], label = "difficult & high discrimination", legend=:bottomright)
plot!(theta, icc[:,3], label = "easy & low discrimination", legend=:bottomright)


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
            for j in 1:J
                Li[j] = x[i, j] == 1 ? icc2pl(xq[m], α[j], β[j]) : 1 - icc2pl(xq[m], α[j], β[j])
            end
            L[i, m] = prod(Li)
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
