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
data = convert(Matrix{Int64}, data)
# Describe generative model
# Version 1
@model irt2pl1(data,  N, J) = begin
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

# Version 2
@model irt2pl2(data,  N, J) = begin
   # p = tzeros(Real, 1)
   θ = tzeros(Real, N)
   α = β = tzeros(Real, J)
   # assign distributon to each element
   for i = 1:N
       for j = 1:J
           θ[i] ~ Normal(0, 1)
           α[j] ~ LogNormal(0, 1)
           β[j] ~ Normal(0, 2)
           p = logistic(α[j]*(θ[i]-β[j]))
           data[i,j] ~ Bernoulli(p)
       end
   end
end

# Vectorize
@model irt2pl3(data,  N, J) = begin
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

@model irt2pl4(data,  N, J) = begin
   θ = Vector{Real}(undef, N)
   α = β = Vector{Real}(undef, J)
   p = Array{Real, 2}(undef, N, J)
   # assign distributon to each element
   θ ~ [Normal(0, 1)]
   α ~ [LogNormal(0, 1)]
   β ~ [Normal(0, 2)]
   for j = 1:J
       p[:,j] = @. logistic(α[j]*(θ-β[j]))
   end
   for i = 1:N
       for j = 1:J
           data[i,j] ~ Bernoulli(p[i,j])
       end
   end
end

N, J = size(data)
iterations = 100
num_chains = 4
ϵ = 0.05
τ = 10
Turing.setadbackend(:forward_diff)

# Comparison MCMC speed and memory consumptions.
@time chain = sample(irt2pl1(data, N, J), HMC(ϵ, τ), iterations); # 2
@time chain = sample(irt2pl2(data, N, J), HMC(ϵ, τ), iterations); # 3
@time chain = sample(irt2pl3(data, N, J), HMC(ϵ, τ), iterations); # 1
@time chain = sample(irt2pl4(data, N, J), HMC(ϵ, τ), iterations); # 1 - (slightly slow, but save more mamory)
