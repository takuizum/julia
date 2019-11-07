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
select!(data, Not(:ID))
for i in 1:size(data, 2)
    data[!,i] = convert(Array{Int64, 1}, data[:,i])
end
data = first(data, 100)

# data = convert(Matrix{Int64}, data)
# Describe generative model
@model irt2pl(data,  N, J) = begin
    θ = Vector{Float64}(undef, N)
    α = β = Vector{Float64}(undef, J)
    # assign distributon to each element
    θ ~ [Normal(0, 1)]
    α ~ [LogNormal(0, 1)]
    β ~ [Normal(0, 2)]
    for i = 1:N
        for j = 1:J
            p = logistic(α[j]*(θ[i]-β[j]))
            data[i,j] ~ Bernoulli(p)
        end
    end

    # for j = 1:J
    #    p = @. logistic(α[j]*(θ-β[j]))
    #    data[!,j] ~ [ Bernoulli.(p) ]
    #    # Right-hand side of a ~ must be subtype of Distribution or a vector of Distributions on line 51.
    #end
end

N, J = size(data)
iterations = 1000
num_chains = 4
ϵ = 0.05
τ = 10
Turing.setadbackend(:forward_diff)
Turing.setadbackend(:reverse_diff) # slower

# sampler option
# https://turing.ml/dev/docs/library/

# NUTS
chain = sample(irt2pl(data, N, J), NUTS(0.65), iterations);
# HMC
chain = sample(irt2pl(data, N, J), HMC(ϵ, τ), iterations);
chain = sample(irt2pl(data, N, J), PG(10), iterations);
# Sepuential Monte Calro
chain = sample(irt2pl(data, N, J), SMC(), iterations); # most fast?
chain = sample(irt2pl(data, N, J), HMCDA(0.15, 0.65), iterations); # Fast!!
chain = sample(irt2pl(data, N, J), MH(), iterations); # Fast, but unstable
chain = sample(irt2pl(data, N, J), SGHMC(), iterations);

# check estimate results
chain[:α]
chain[:β]
chain[:θ]


# MAP estimation
function get_nlogp(model)
    # Set up the model call, sample from the prior.
    vi = Turing.VarInfo(model)

    # Define a function to optimize.
    function nlogp(sm)
        spl = Turing.SampleFromPrior()
        new_vi = Turing.VarInfo(vi, spl, sm)
        model(new_vi, spl)
        -new_vi.logp
    end

    return nlogp
end

using Optim
# How to set initial value ?
map_result = optimize(get_nlogp(irt2pl1(data, N, J)), LBFGS())

get_nlogp(irt2pl1(data, N, J))

model = irt2pl1(data, N, J)
vi = Turing.VarInfo(model)
spl = Turing.SampleFromPrior()
Turing.VarInfo(vi)
vi.logp
