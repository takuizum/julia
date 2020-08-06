using Turing
using Distributions, StatsFuns

@model poIRT(data) = begin
    N, J = size(data)
    θ = Vector(undef, N)
    β = Vector(undef, J)
    ω = Matrix(undef, N, J) # Discrete latant variable
    ϕ = Vector(undef, N)

    for j in 1:J
        β[j] ~ Normal(0, 2)
    end
    for i in 1:N
        ϕ[i] ~ Beta(1, 5)
        θ[i] ~ Normal(0, 1)
    end
    for i in 1:N, j in 1:J
        ω[i, j] ~ Bernoulli(ϕ[i])
    end

    for i in 1:N
        for j in 1:J
            if ω == 1
                p = (θ[i] - β[j]) / 10^3 # κ = 10^3
            else
                p = θ[i] - β[j]
            end
            data[i,j] ~ BinomialLogit(1, p)
        end
    end
end

@model GIRT(data) = begin
    N, J = size(data)
    θ = Vector(undef, N)
    ϕ = Vector(undef, N)
    β = Vector(undef, J)
    α = Vector(undef, J)
    # prior setting
    # β ~ MvNormal(fill(0, J), 2)
    # α ~ MvLogNormal(fill(0, J), 2)
    # θ ~ MvNormal(fill(0, N), 1)
    # ϕ ~ MvLogNormal(fill(0, N), 2)
    for i in 1:N
        θ[i] ~ Normal(0, 1)
        ϕ[i] ~ LogNormal(0, 2)
    end
    for j in 1:J
        β[j] ~ Normal(0, 2)
        α[j] ~ LogNormal(0, 2)
    end
    # transformed parameters
    z = Matrix(undef, N, J)
    for i in 1:N, j in 1:J
        z[i,j] = ((α[j]*ϕ[i]) / sqrt(α[j]^2 + ϕ[i]^2))*(θ[i] - β[j])
    end
    for i in 1:N
        for j in 1:J
            data[i,j] ~ BinomialLogit(1, z[i,j])
        end
    end
end

@model Rasch(data) = begin
    N, J = size(data)
    θ = Vector(undef, N)
    β = Vector(undef, J)

    for j in 1:J
        β[j] ~ Normal(0, 2)
    end
    for i in 1:N
        θ[i] ~ Normal(0, 1)
    end
    for i in 1:N
        for j in 1:J
            p = logistic(θ[i] - β[j])
            data[i,j] ~ Bernoulli(p)
        end
    end
end

using RCall
R"""
library(irtoys)
data <- Scored
"""
@rget data
data = convert(Matrix{Int64}, data)

model = poIRT(data)
varinfo = Turing.VarInfo(model)
spl = Turing.SampleFromPrior()
@code_warntype model.f(varinfo, spl, Turing.DefaultContext(), model)

chain = sample(Rasch(data), NUTS(100, 0.65), 500);
chain = sample(GIRT(data), NUTS(200, 0.65), 2000);
chain = psample(GIRT(data), HMCDA(200, 0.65, 0.3), 2000, 4);
chain = sample(poIRT(data), SMC(), 1000);
# multiple chains
chains = mapreduce(c -> sample(GIRT(data), NUTS(200, 0.65), 2000, discard_adapt=false), chainscat, 1:4);

R"""
library(mirt)
fit <- mirt(as.data.frame(data), 1, "Rasch")
pars <- coef(fit, simplify = TRUE)$items
"""

@rget pars
@show summarystats(chain)

using StatsPlots
plot(chain[:,:α,:])
plot(chain[:,:β,:])
