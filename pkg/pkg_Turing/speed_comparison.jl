using Turing, RCall
using DataFramesMeta, DataFrames, StatsFuns

R"""
# Get toy data
library(irtfun2)
data <- sim_data_2
"""
data = Any; #  dummy for linting
@rget data
# @linq data |> select!(2:31)
select!(data, Not(:ID))
for i in 1:size(data, 2)
    data[!,i] = convert(Array{Int64, 1}, data[:,i])
end
data = first(data, 1000)
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
   for i = 1:N, j = 1:J
       p = logistic(α[j]*(θ[i]-β[j]))
       data[i,j] ~ Bernoulli(p)
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
   for j = 1:J, i = 1:N
       data[i,j] ~ Bernoulli(p[i,j])
   end
end

# Vectorize
function pivot_response(df::DataFrame)
    ROW, COL = size(df)
    item_name = names(df)
    item_loc = [1:1:COL;] |> x -> map(Symbol, x)
    name_loc_dict = Dict(item_name[i] => item_loc[i] for i in 1:COL)
    df = rename(df, name_loc_dict)
    item_name = names(df) # overwrite
    df.sloc = 1:ROW # add col
    df = stack(df, item_name, :sloc, variable_name = :iloc, value_name = :response)
    df.iloc = map(sym -> String(sym), df.iloc) |> x -> map(str -> parse(Int64, str), x)
    # @show last(df, 10)
    return df
end

@model irt2pl5(data, N, J) = begin
   θ = Vector{Real}(undef, N)
   α = β = Vector{Real}(undef, J)
   p = Vector{Real}(undef, N*J)
   # assign distributon to each element
   θ ~ [Normal(0, 1)]
   α ~ [LogNormal(0, 1)]
   β ~ [Normal(0, 2)]
   # for i in 1:N*J
    #   p[i] = logistic(α[data[i,:iloc]]*(θ[data[i,:sloc]]-β[data[i,:iloc]]))
   #end
   p =  @. logistic(α[data.iloc]*(θ[data.sloc]-β[data.iloc]))
   for i in 1:N*J
       data[i,:response] ~ Bernoulli(p[i])
   end
   # data[!, :response] ~ Bernoulli.(p)
end

@rget data
# @linq data |> select!(2:31)
select!(data, Not(:ID))
for i in 1:size(data, 2)
    data[!,i] = convert(Array{Int64, 1}, data[:,i])
end
data = first(data, 3000)

N, J = size(data)
iterations = 100
num_chains = 4
ϵ = 0.05
τ = 10
η = .65
Turing.setadbackend(:forward_diff)
Turing.setadbackend(:reverse_diff) # slower

# Comparison MCMC speed and memory consumptions.
@time chain = sample(irt2pl1(data, N, J), HMC(ϵ, τ), iterations); # 2
@time chain = sample(irt2pl2(data, N, J), HMC(ϵ, τ), iterations); # 3
@time chain = sample(irt2pl3(data, N, J), HMC(ϵ, τ), iterations); # 1
@time chain = sample(irt2pl4(data, N, J), HMC(ϵ, τ), iterations); # 1 - (slightly slow, but save more mamory)
@time chain = sample(irt2pl5(pivot_response(data), N, J), HMC(ϵ, τ), iterations); #

# Compare in NUTS
@time chain = sample(irt2pl4(data, N, J), NUTS(η), iterations);
@time chain = sample(irt2pl5(pivot_response(data), N, J), NUTS(η), iterations);

# Compare speed in different data type
data2 = convert(Matrix, data)
@time chain = sample(irt2pl4(data, N, J), HMC(ϵ, τ), iterations);
@time chain = sample(irt2pl4(data2, N, J), HMC(ϵ, τ), iterations);
@time chain = sample(irt2pl4(data2', J, N), HMC(ϵ, τ), iterations);

# NUTS vs HMC
@time chain_HMC  = sample(irt2pl4(data2, N, J), HMC(ϵ, τ), iterations);
@time chain_NUTS = sample(irt2pl4(data2, N, J), NUTS(.65), iterations);
