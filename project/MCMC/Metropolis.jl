using Distributions, Random, Plots, Printf

# ising simulation
inc(x) = x ÷ 30 + 1
dec(x) = (x + 28) ÷ 30 + 1
init_state(n) = [ rand([-1, 1]) for i in 1:n, j in 1:n]

function ising_2d(N, size, kT, marksize = 5, fontsize = 10)
    s = init_state(size)
    ssum = zero(eltype(s))
    ROW = vcat( fill([1:1:size;], size)...)
    COL = [fill(i, size) for i in 1:size] |> x -> vcat(x...)
    coord = [1:1:size;]
    @animate for kT_ in kT, g in 1:N
        i = rand(coord)
        j = rand(coord)
        dE = 2*s[i,j] * (s[i,dec(j)] + s[i,inc(j)] + s[dec(i),j] + s[inc(i),j])
        if(dE < 0)
            s[i,j] = -s[i,j]
        else
            p = exp(-dE/kT_)
            r = wsample([-1, 1], [p, 1-p])
            s[i,j] = s[i,j] * r
        end
        ssum += s[i,j]
        if( (g % 1e4) ≥ 0 )
            print("磁化率 = $(ssum/g) \r")
            state = vcat(s...) |>  x -> x .== 1
            state = ifelse.(state, :black, :white)
            scatter(ROW, COL, markercolor = state, markersize = marksize,
                    legend = false,
                    aspect_ratio = 1)
            annotate!(size/2, size+1, "$(@sprintf("%.0f", g)) times Ising Simulation. kT = $(@sprintf("%.3f",kT_)). Magnetic susceptibility = $(@sprintf("%.3f", ssum/g))",
                      font(fontsize))
            # title!("$(@sprintf("%.0f", g)) times Ising Simulation\nkT = $(@sprintf("%.3f",kT_)),\nMagnetic susceptibility = $(@sprintf("%.3f", ssum/g))")
        end
    end
end

anim = ising_2d(1e2, 30, 3)
gif(anim)
scatter(ROW, COL, markercolor = state, markersize = 8, legend = false,
        aspect_ratio = 1)

# MH sampler for Gaussian mean and variance
using Turing, Distributions, StatsPlots
@model gaussian_mean_var(y) = begin
    μ ~ Normal(0, 3)
    σ ~ Chisq(2)
    N = size(y, 1)
    for i in 1:N
        y[i] ~Normal(μ, σ)
    end
end

y = rand(Normal(0, 1), 1000)

iterations = 10000
chain_gmv_MH = sample(gaussian_mean_var(y), MH(), iterations)
plot(chain_gmv_MH[[:μ, :σ]])

iterations = 1000
η = 0.65
chain_gmv_NUTS = sample(gaussian_mean_var(y), NUTS(η), iterations)
plot(chain_gmv_NUTS[[:μ, :σ]])

iterations = 1000
η = 0.65
chain_gmv_HMC = sample(gaussian_mean_var(y), HMC(.01, 10), iterations)
plot(chain_gmv_HMC[200:1000, [:μ, :σ], :])
