# Interact Plots
using Pkg; Pkg.add ORCA PlotlyJS CSSUtil Interact

using Interact, Plots, StatsFuns, PlotlyJS


@manipulate for α in slider(0.0001:0.001:3)
    θ = [-4:0.001:4;]
    β = 0
    prob = logistic.((θ.-β)*α)
    plot(θ, prob)
end

#%%
plotlyjs()
@manipulate for α in slider(0.0001:0.1:3)
    @manipulate for β in slider(-4:0.1:4)
        θ = [-4:0.001:4;]
        prob = logistic.((θ.-β)*α)
        prob = logistic.((θ.-β)*α)
        plot(θ, prob)
    end
end
#%%
