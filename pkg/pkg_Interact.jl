# Interact Plots
using Pkg; Pkg.add ORCA PlotlyJS CSSUtil Interact

using Interact, Plots, StatsFuns, CSSUtil# , PlotlyJS, ORCA,

@manipulate for α in slider(0.0001:0.001:3)
    θ = [-4:0.001:4;]
    β = 0
    prob = logistic.((θ.-β)*α)
    plot(θ, prob)
end

#%%
plotlyjs()
gr() # こっちだとヌルヌル動くようになる。
@manipulate for α = 0:0.01:3, β = -4:0.01:4, γ = 0:.01:1
        θ = [-4:0.001:4;]
        prob = γ .+ (1-γ).*logistic.((θ.-β)*α)
        plot(θ, prob,
        label = "ICC",
        xlabel = "theta", ylabel = "Correct probability",
        xlims = (-4, 4), ylims = (0, 1))
    end
#%%

ui = @manipulate throttle = 0.1 for r = 0:.05:1, g = 0:.05:1, b = 0:.05:1
     HTML(string("<div style='color:#", hex(RGB(r,g,b)), "'>Color me</div>"))
 end
 @layout! ui dom"div"(observe(_), vskip(2em), :r, :g, :b)
 ui
