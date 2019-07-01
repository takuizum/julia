# Graded Response Model
using Distributions, Random, StatsFuns, Plots

function pgrm(θ::Float64, α::Float64, b0::Union{Float64, Missing}, b1::Union{Float64, Missing})::Float64
    if typeof(b0) == Float64 && typeof(b1) == Float64
        logistic(α*(θ-b0)) - logistic(α*(θ-b1))
    elseif typeof(b0) == Missing
        logistic(α*(θ-b1)) - 0
    else typeof(b1) == Missing
        1 - logistic(α*(θ-b0))
    end
end

pgrm(1.5, 1.0, missing, 1.0)

# 項目パラメタのリストの作り方
A = Array{Union{Missing, Int64}, 2}(missing, 2 ,2)

B = Matrix{Union{Int64, Missing}}(undef, 3, 3)
B[1,1] = 1
B[2,:]
[1, 2, 3]
A = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] # Array in Array が良さそう。
A[1] # 1 dim array

N = 5000,; J = 30; M = 31

by = (4-(-4))/(M-1)
xq = collect(-4:by:4)
aq = pdf.(Normal(), xq) ./ sum(pdf.(Normal(), xq))
L = zeros(N, length(xq))
Gim = zeros(N, length(xq))
for i in 1:N
    for m in 1:M
        Li = 1.0
        for j in 1:J
            Li *= pgrm(xq[m], α[j], b[resp[i,j]+1], b[resp[i,j]])
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
