# mixture poisson

using Distributions, StatsBase, StatsFuns, Plots, Random

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


function vb(X, nK)
    N = length(X)
    # initialize distribution (Expectation)
    λ0 = fill(mean(Gamma(5, 5)), nK)
    π0 = fill(1, nK) / nK
    # Expectation of Sn
    η1 = [exp(X[n]*log(λ0[k]) - λ0[k] + log(π0[k])) for n in 1:N, k in 1:nK]
    # Expectation of λ
    for i in 1:N
        η1[i,:] .= η1[i,:] / sum(η1[i,:])
    end
    a1 = zeros(1) # hyper α
    for i in 1:N
        a1 += mean(Categorical(η1[i,:])) * X[i]
    end
