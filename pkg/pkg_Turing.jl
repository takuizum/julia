# Quick start

# 2019/11/06
# add Zygote#master で引っかかってくるPkgをすべてrmすればZygoteのprecompileは実行できた。
# 最新版のZygoteではbuildエラーが起こるようなので，masterからとってくること。
]add Turing#master
# masterがら引っ張ってきたいが，依存するPkgの要求するバーションを満たしていないので，却下される模様。
]add ZygoteRules#master
]add Zygote#master

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
