# Graded Response Model
using Distributions, Random, StatsFuns, Plots

function pgrm(θ, α, b0::Union{Float64, Missing}, b1::Union{Float64, Missing})
    if typeof(b0) <: Real && typeof(b1) <: Real
        logistic(α*(θ-b0)) - logistic(α*(θ-b1))
    elseif typeof(b0) == Missing
        1 - logistic(α*(θ-b1))
    else#  typeof(b1) == Missing
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
A[2] # 1 dim array

N = 5000; J = 30; M = 31
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

x = resgen_graded(5000, sample(3:5, 30))
x.β
# using StatsBase, Plots
# plot(fit(Histogram, wsample([1,2,3], [0.1, 0.1, 0.7], 10000)))

# intial value
α0 = repeat([1], J)
β0 = x.β
resp = x.resp

# categories number in each items
K = Array{Array{Int64, 1},1}(undef, J)
for j in 1:J
    K[j] = unique(resp[:,j])
end

by = (4-(-4))/(M-1)
xq = collect(-4:by:4)
aq = pdf.(Normal(), xq) ./ sum(pdf.(Normal(), xq))

# Estep

prob = zeros(J, 5, M)
for m in 1:M
    for j in 1:J
        for k in K[j]
            prob[j,k,m] = pgrm(xq[m], α0[j], β0[j][k], β0[j][k+1])
            # 内包表記は？
            # prob[pgrm(xq[m], α0[j], β0[j][k], β0[j][k+1]) for j = 1:J, k = K[j], m = 1:M]
            # pa  = prob[j,k,m] * aq[m]
            # r[j,k,m] = sum(pa  .* resp[:,j][resp[:,j] .== k])
        end
    end
end


L = zeros(N, length(xq))
Gim = zeros(N, length(xq))
for i in 1:N
    for m in 1:M
        Li = 1.0
        for j in 1:J
            Li *= prob[j,:,m][resp[i,j]]
        end
        L[i,m] = Li
        Gim[i,m] = Li * aq[m]
    end
end
Pm = sum(Gim, dims = 2)

F = r = zeros(J, 5, M)
for m in 1:M
    for j in 1:J
        for k in K[j]
            pa = prob[j,k,m] .* aq[m]
            uijk = resp[:,j][resp[:,j] .== k]
            r[j,k,m] = sum(pa * uijk)
            F[j,k,m] = pa * length(uijk)
        end
    end
end
sum(F, dims = (1, 2, 3))
