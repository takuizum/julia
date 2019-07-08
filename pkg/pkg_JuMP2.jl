using JuMP, GLPK, Random, Distributions

# generate sample item paraemters

α = rand(LogNormal(-0.5, 0.7), 90)
histogram(α)
β = rand(Normal(0, 1.5), 90)
scatter(α, β)

mod1 = Model(with_optimizer(GLPK.Optimizer))
@variable(mod1,0 =< x =< 1)
