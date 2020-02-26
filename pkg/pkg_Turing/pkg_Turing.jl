# Quick start

# 2019/11/06
# add Zygote#master で引っかかってくるPkgをすべてrmすればZygoteのprecompileは実行できた。
# 最新版のZygoteではbuildエラーが起こるようなので，masterからとってくること。
# add Turing#master
# # masterがら引っ張ってきたいが，依存するPkgの要求するバーションを満たしていないので，却下される模様。
# ]add ZygoteRules#master
# ]add Zygote#master

# 2020/02/26
# GitHubの更新頻度が結構高いようなので，こちらからinstallする。
# ]add https://github.com/TuringLang/Turing.jl

using Turing, StatsPlots, Random

# Set the true probability of heads in a coin. # ベルヌーイ試行の母数を設定
p_true = 0.5

# Iterate from having seen 0 observations to 100 observations. # 試行回数をベクトルで定義
Ns = 0:100;

# Draw data from a Bernoulli distribution, i.e. draw heads or tails. #
Random.seed!(12)
data = rand(Bernoulli(p_true), last(Ns))

# Declare our Turing model.
@model coinflip(y) = begin
    # Our prior belief about the probability of heads in a coin.
    p ~ Beta(1, 1)

    # The number of observations.
    N = length(y)
    for n in 1:N
        # Heads or tails of a coin are drawn from a Bernoulli distribution.
        y[n] ~ Bernoulli(p)
    end
end;

# Settings of the Hamiltonian Monte Carlo (HMC) sampler.
iterations = 1000
ϵ = 0.05
τ = 10

# Start sampling.
chain = sample(coinflip(data), HMC(ϵ, τ), iterations);

# Plot a summary of the sampling process for the parameter p, i.e. the probability of heads in a coin.
histogram(chain[:p])

# Gaussian Mixture Model
using Distributions, StatsPlots, Random

# Set a random seed.
Random.seed!(3)
# Construct 30 data points for each cluster.
N = 30
# Parameters for each cluster, we assume that each cluster is Gaussian distributed in the example.
μs = [-3.5, 0.0]
# Construct the data points.
x = mapreduce(c -> rand(MvNormal([μs[c], μs[c]], 1.), N), hcat, 1:2)
# Visualization.
scatter(x[1,:], x[2,:], legend = false, title = "Synthetic Dataset")

using Turing, MCMCChains
# Turn off the progress monitor.
Turing.turnprogress(false)
# model
@model GaussianMixtureModel(x) = begin
    D, N = size(x)
    # Draw the paramters for cluster 1.
    μ1 ~ Normal()
    # Draw the paramters for cluster 2.
    μ2 ~ Normal()
    μ = [μ1, μ2]
    # Uncomment the following lines to draw the weights for the K clusters
    # from a Dirichlet distribution.
    # α = 1.0
    # w ~ Dirichlet(2, α)
    # Comment out this line if you instead want to draw the weights.
    w = [0.5, 0.5]
    # Draw assignments for each datum and generate it from a multivariate normal.
    k = Vector{Int}(undef, N)
    for i in 1:N
        k[i] ~ Categorical(w)
        x[:,i] ~ MvNormal([μ[k[i]], μ[k[i]]], 1.)
    end
    return k
end

Turing.setadbackend(:forward_diff)

gmm_model = GaussianMixtureModel(x);
gmm_sampler = Gibbs(100, PG(100), HMC(0.05, 10, :μ1, :μ2))
tchain = mapreduce(c -> sample(gmm_model, gmm_sampler), chainscat, 1:3); # Error
chns = sample(GaussianMixtureModel(x), HMC(0.05, 10, :μ1, :μ2), 1000) # Working
density([chns[:μ1] chns[:μ2]])

ids = findall(map(name -> occursin("μ", name), names(chns)));
p=plot(chns[:, ids, :], legend=true, labels = ["Mu 1" "Mu 2"], colordim=:parameter)

tchain = tchain[:, :, 1];

# Helper function used for visualizing the density region.
function predict(x, y, w, μ)
    # Use log-sum-exp trick for numeric stability.
    return Turing.logaddexp(
        log(w[1]) + logpdf(MvNormal([μ[1], μ[1]], 1.), [x, y]),
        log(w[2]) + logpdf(MvNormal([μ[2], μ[2]], 1.), [x, y])
    )
end

contour(range(-5, stop = 3), range(-6, stop = 2),
    (x, y) -> predict(x, y, [0.5, 0.5], [mean(tchain[:μ1].value), mean(tchain[:μ2].value)])
)
scatter!(x[1,:], x[2,:], legend = false, title = "Synthetic Dataset")

assignments = collect(skipmissing(mean(tchain[:k].value, dims=1).data))
scatter(x[1,:], x[2,:],
    legend = false,
    title = "Assignments on Synthetic Dataset",
    zcolor = assignments)
