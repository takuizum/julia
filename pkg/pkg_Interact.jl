# Interact Plots
using Pkg; Pkg.add ORCA PlotlyJS CSSUtil Interact

using Interact, Plots, StatsFuns, PlotlyJS, ORCA, CSSUtil

@manipulate for α in slider(0.0001:0.001:3)
    θ = [-4:0.001:4;]
    β = 0
    prob = logistic.((θ.-β)*α)
    plot(θ, prob)
end

#%%
plotlyjs()
@manipulate for α in 0.0001:0.1:3, β in -4:0.1:4
        θ = [-4:0.001:4;]
        prob = logistic.((θ.-β)*α)
        prob = logistic.((θ.-β)*α)
        plot(θ, prob)
    end
end
#%%

ui = @manipulate throttle = 0.1 for r = 0:.05:1, g = 0:.05:1, b = 0:.05:1
     HTML(string("<div style='color:#", hex(RGB(r,g,b)), "'>Color me</div>"))
 end
 @layout! ui dom"div"(observe(_), vskip(2em), :r, :g, :b)
 ui
