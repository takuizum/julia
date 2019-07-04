# mixture poisson

using Distributions, StatsBase, StatsFuns, Plots, Random, SpecialFunctions, Distances

# Poisson's hyper parameter is λ
N = 10000
nK = 4

Sn =  rand(Categorical([0.5, 0.5]), N)# latent cluster

Khyper = [2 3; 1 10; 5 10; 20 1]
plot([0:0.01:20;], pdf.(Gamma(Khyper[1,1], Khyper[1,2]), [0:0.01:20;]))
plot!([0:0.01:20;], pdf.(Gamma(Khyper[2,1], Khyper[2,2]), [0:0.01:20;]))
plot!([0:0.01:20;], pdf.(Gamma(Khyper[3,1], Khyper[3,2]), [0:0.01:20;]))
plot!([0:0.01:20;], pdf.(Gamma(Khyper[4,1], Khyper[4,2]), [0:0.01:20;]))

λ = [rand(Gamma(Khyper[i,1], Khyper[i,2])) for i in [1 4] ]
X = [ rand(Poisson(λ[Sn[i]]), 1)[1] for i in 1:length(Sn)]
plot(fit(Histogram, X))

nK = 4

struct MixturePoissonVB
    η
    λ
    shape
    scale
    α
end

# KL divergence
# kl_divergence()
#function ELBO_PMM(X, η, nK, pri_a, pri_b, pos_a, pos_b)
#    ln_pxsλ = zeros(1)
#    for k in 1:nK
#        ln_pxsλ +=
#    end # of N
#end

function vb(X, nK, MAXITER = 10,
            a = sample([1:1:40;], nK), # Gamma hyper param(shape)
            b = sample([1:1:40;], nK), # Gamma hyper param(scale)
            α = sample([1:1:40;], nK)  # Dirichrret hyper param
            )
    N = length(X)
    # initialize distribution (Expectation)
    Sn =  rand(Categorical(ones(nK)/nK), N)# cluster
    S = zeros(Int64, N, nK)
    println("Initialize latent matrix")
    for k in 1:nK
        S[findall(x->x==k, Sn), k] .= 1
    end
    SnX =  S' * X
    sumS = sum(S', dims = 2)
    println("Initialize parameter vectors")
    # empty vectors
    a1 = zeros(nK);b1 = zeros(nK);α1 = zeros(nK)
    lnλ1 = zeros(nK);lnπ1 = zeros(nK);λ1 = zeros(nK)
    η1 = zeros(N, nK)
    for k in 1:nK
        a1[k] = SnX[k] + a[k]
        b1[k] = sumS[k] + b[k]
        α1[k] = sumS[k] + α[k]
        λ1[k] = a1[k] / b1[k]
        lnλ1[k] = digamma(a1[k]) - log(b1[k])
        lnπ1[k] = digamma(α1[k]) - digamma(sum(α1))
    end
    # START VB ITERATION
    ITER = 0
    while ITER < (MAXITER + 1)
        print("Itaration", ITER, "... λ is ", λ1 ,"\r")
        ITER += 1
        # Expectation of Sn
        for i in 1:N
            η1[i,1:nK] = exp.(X[i] * lnλ1 - λ1 + lnπ1)
            η1[i,:] = η1[i,:] / sum(η1[i,:]) # shoud use logsumexp ?
        end
        # Expectation of λ and π
        ηX =  η1' * X
        sumη = sum(η1', dims = 2) # total probability of each cluster
        for k in 1:nK
            a1[k] = ηX[k] + a[k]
            b1[k] = sumη[k] + b[k]
            α1[k] = sumη[k] + α[k]
            λ1[k] = a1[k] / b1[k]
            lnλ1[k] = digamma(a1[k]) - log(b1[k])
            lnπ1[k] = digamma(α1[k]) - digamma(sum(α1))
        end
    end # of while
    println("ITERATIONS REACHED MAXITER")
    MixturePoissonVB(η1, λ1, a1, b1, α1)
end # of function

res = vb(X, 4, 100, Khyper[:,1], Khyper[:,2], [1.0,1.0,1.0,1.0])
res = vb(X, 3, 10, [2,7,10], [2,2,2], [1.0,1.0,1.0])
@time res = vb(X, 2, 1000)

# どうやら4回の周期でおなじイテレーションを繰り返しているようで，全然収束していない。

[res.η X Sn]

# 分類結果の確認

which_max = zeros(N)
for i in 1:N
    which_max[i] = findall(x->x==maximum(df_tmp[1,:]),  df_tmp[1,:])
end

iszero(which_max .- Sn)

@which count(iszero, which_max .- Sn)
