# mixture poisson

using Distributions, StatsBase, StatsFuns, Plots, Random, SpecialFunctions

# Poisson's hyper parameter is λ
plot(fit(Histogram, rand(Poisson(), 10000), nbins = 20))

Sn = sample(Random.GLOBAL_RNG, [1:1:4;], 10000) # cluster
Khyper = [2 3; 1 10; 5 10; 20 1]

plot([0:0.01:20;], pdf.(Gamma(Khyper[1,1], Khyper[1,2]), [0:0.01:20;]))
plot!([0:0.01:20;], pdf.(Gamma(Khyper[2,1], Khyper[2,2]), [0:0.01:20;]))
plot!([0:0.01:20;], pdf.(Gamma(Khyper[3,1], Khyper[3,2]), [0:0.01:20;]))
plot!([0:0.01:20;], pdf.(Gamma(Khyper[4,1], Khyper[4,2]), [0:0.01:20;]))

λ = [rand(Gamma(Khyper[i,1], Khyper[i,2])) for i in 1:4 ]
X = [ rand(Poisson(λ[Sn[i]]), 1)[1] for i in 1:length(Sn)]
plot(fit(Histogram, X))

nK = 4
function vb(X, nK, a, b)
    N = length(X)
    # hyper parameters
    a = sample([1:1:40;], nK); b = sample([1:1:40;], nK); α = sample([1:1:40;], nK)
    # initialize distribution (Expectation)
    λ0 = a ./ b
    lnλ0 = zeros(nK)
    lnπ0 = zeros(nK)
    for k in 1:nK
        lnλ0[k] = digamma(a[k]) - log(b[k])
        lnπ0[k] = digamma(α[k]) - digamma(sum(α))
    end
    η1 = [exp(X[n]*lnλ0[k] - λ0[k] + lnπ0[k]) for n in 1:N, k in 1:nK]
    for i in 1:N
        η1[i,:] .= η1[i,:] / sum(η1[i,:])
    end
    # Expectation of λ and π

    # a1 = zeros(nK) # hyper α
    # sn1 = mean(η1, dims = 2)

    a1 = sum(η1 .* X, dims = 1) + a'
    b1 = sum(η1, dims = 1) + b'
    α1 = sum(η1, dims = 1) + α'
    λ1 = a1 ./ b1
    lnλ1 = zeros(nK)
    lnπ1 = zeros(nK)
    for k in 1:nK
        lnλ1[k] = digamma(α1[k]) - log(b1[k])
        lnπ1[k] = digamma(α1[k]) - digamma(sum(α1))
    end
    # Expectation of Sn
    η1 = [exp(X[n]*lnλ1[k] - λ1[k] + lnπ1[k]) for n in 1:N, k in 1:nK]
    # Expectation of λ and π
    for i in 1:N
        η1[i,:] .= η1[i,:] / sum(η1[i,:])
    end
    # ELBO
