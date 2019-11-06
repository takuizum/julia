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


# IRT run test
using Turing, RCall
using DataFramesMeta, DataFrames, StatsFuns

# Get toy data
R"""
library(irtfun2)
data <- sim_data_2
"""
@rget data
# @linq data |> select!(2:31)
deletecols!(data, :ID)
for i in 1:size(data, 2)
    data[:,i] = convert(Array{Int64, 1}, data[:,i])
end
first(data, 10)

# data = convert(Matrix{Int64}, data)
# Describe generative model
@model irt2pl(data,  N, J) = begin
    θ = tzeros(Real, N)
    α = β = tzeros(Real, J)
    # assign distributon to each element

    for i in 1:N
        θ[i] ~ Normal(0, 1)
        for j in 1:J
            α[j] ~ LogNormal(0, 1)
            β[j] ~ Normal(0, 2)
            x = α[j]*(θ[i]-β[j])
            p = 1 / (1 + exp(-x))
            # p = logistic(α[j]*(θ[i]-β[j]))
            data[i,j] ~ Bernoulli(p)
        end
    end
end

N, J = size(data)
iterations = 1000
num_chains = 4
chain = sample(irt2pl(data, N, J), NUTS(), iterations);
mapreduce(c -> sample(irt2pl(data), NUTS(2500, 200, 0.65) ), chainscat, 1:num_chains)
