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
data = first(data, 3000)
data = convert(Matrix{Int64}, data)

# data = convert(Matrix{Int64}, data)
# Describe generative model
@model irt2pl(data,  N, J) = begin
   θ = tzeros(Real, N)
   α = β = tzeros(Real, J)
   # assign distributon to each element
   for i in 1:N
       θ[i] ~ Normal(0, 1)
   end
   for j in 1:J
       α[j] ~ LogNormal(0, 1)
       β[j] ~ Normal(0, 2)
   end
   for i = 1:N
       for j = 1:J
           p = logistic(α[j]*(θ[i]-β[j]))
           data[i,j] ~ Bernoulli(p)
       end
   end
end

N, J = size(data)
iterations = 2000
num_chains = 4
ϵ = 0.05
τ = 10
Turing.setadbackend(:forward_diff)
Turing.setadbackend(:reverse_diff) # slower

# sampler option
# https://turing.ml/dev/docs/library/

# NUTS
chain_NUTS = sample(irt2pl(data, N, J), NUTS(0.65), iterations);
# HMC
chain_HMC = sample(irt2pl(data, N, J), HMC(ϵ, τ), iterations);
chain_PG = sample(irt2pl(data, N, J), PG(10), iterations);
# Sepuential Monte Calro
chain = sample(irt2pl(data, N, J), SMC(), iterations); # most fast?
chain_HMCDA = sample(irt2pl(data, N, J), HMCDA(0.15, 0.65), iterations); # Fast!!
chain_MH = sample(irt2pl(data, N, J), MH(5000)); # Fast, but unstable and not support vectorize
chain_SGHMC = sample(irt2pl(data, N, J), SGHMC(.01, .1), iterations);
chain_IS = sample(irt2pl(data, N, J), IS(), 5000);
chain_Gibbs = sample(irt2pl(data, N, J), Gibbs(MH(:α), MH(:β), MH(:θ)), 1000);


# check estimate results
using StatsPlots
chain_Gibbs
plot(chain_Gibbs[:β])
mean(chain_Gibbs[:α][:,1,1])

using KernelDensity
kde(chain_Gibbs[:α][:,1,1])

# MAP estimation
using Optim
model = irt2pl(data, N, J)
vi = Turing.VarInfo()
model(vi, Turing.SampleFromPrior())
function nlogp(sm)
    vi.vals .= sm
    model(vi, Turing.SampleFromPrior())
    -vi.logp
end

sm_0 = Float64.(vi.vals)
lb = [fill(-10., 3000); fill(0., 30)  ; fill(-10., 30)]
ub = [fill(10., 3000);  fill(10., 30); fill(10., 30)]
result = optimize((v)->nlogp(v), lb, ub, sm_0, Fminbox())
result = optimize(nlogp, lb, ub, sm_0, NelderMead())
result.minimizer[1001:1060]
