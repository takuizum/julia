using Turing
using Distributions, StatsFuns

@model poIRT(data) = begin
    N, J = size(data)
    θ = Vector(undef, N)
    β = Vector(undef, J)
    z = Matrix(undef, N, J)
    ε = Matrix(undef, N, J)
    ω = Matrix(undef, N, J) # Discrete latant variable
    ϕ = Vector(undef, N)

    for i in 1:N
        ϕ[i] ~ Beta(1, 5)
        θ[i] ~ Normal(0, 1)
        for j in 1:J
            β[j] ~ Normal(0, 2)
            ω[i, j] ~ Bernoulli(ϕ[i])
            if ω == 1
                ε[i, j] ~ Normal(0, 10^3)
            else
                ε[i, j] ~ Normal(0, 1)
            end
        end
    end
    for i in 1:N
        for j in 1:J
           data[i,j] ~ Bernoulli(cdf(Normal(0, 1), (θ[i] - β[j]) / ε[i, j]))
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


chain = sample(poIRT(data), HMC(0.05, 10), 1000);
