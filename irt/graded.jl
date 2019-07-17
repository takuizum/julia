# Graded Response Model
using Distributions, Random, StatsFuns, Plots

function pgrm(θ, α, b0::Union{Float64, Missing}, b1::Union{Float64, Missing})
    if typeof(b0) <: Real && typeof(b1) <: Real
        logistic(α*(θ-b0)) - logistic(α*(θ-b1))
    elseif typeof(b0) == Missing
        1 - logistic(α*(θ-b1))
    else typeof(b1) == Missing
        logistic(α*(θ-b0)) - 0
    end
end

pgrm(1.5, 1.0, missing, 1.0)

# 項目パラメタのリストの作り方
A = Array{Union{Missing, Int64}, 2}(missing, 2 ,2)

B = Matrix{Union{Int64, Missing}}(undef, 3, 3)
B[1,1] = 1
B[2,:]
[1, 2, 3]'
A = [[1, 2, 3], [4, 5], [7, 8, 9]] # Array in Array が良さそう。
A[1] # 1 dim array

N = 5000,; J = 30; M = 31
struct simgenClassGraded
    resp::Array{Int64,2}
    θ::Array{Float64,1}
    α::Array{Float64,1}
    β
end

# generate sim data
function resgen_graded(N, K)
    θ = rand(Normal(), N)
    α = rand(LogNormal(), length(K))
    β = [[missing; sort(rand(Normal(), K[j]-1), rev = false); missing] for i=1, j=1:length(K)]
    resp = zeros(Int64, N ,length(K))
    for i in 1:N
        for j in 1:length(K)
            prob = zeros(K[j])
            for k in 1:K[j]
                prob[k] = pgrm(θ[i], α[j], β[j][k], β[j][k+1])
            end
            resp[i,j] = wsample(1:K[j], prob, 1)[1]
        end
    end
    simgenClassGraded(resp, θ, α, β)
end # of function

x = resgen_graded(5000, [3,3,3,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4])

# using StatsBase, Plots
# plot(fit(Histogram, wsample([1,2,3], [0.1, 0.1, 0.7], 10000)))

by = (4-(-4))/(M-1)
xq = collect(-4:by:4)
aq = pdf.(Normal(), xq) ./ sum(pdf.(Normal(), xq))
L = zeros(N, length(xq))
Gim = zeros(N, length(xq))
for i in 1:N
    for m in 1:M
        Li = 1.0
        for j in 1:J
            Li *= pgrm(xq[m], α[j], β[j][resp[i,j]], β[j][resp[i,j]+1])
        end
        L[i,m] = Li
        Gim[i,m] = Li * aq[m]
    end
    if(m == length(xq))
        for i in 1:N
            Gim[i,m] = Gim[i,m]/sum(Gim[i,:])
        end
    end
end
