# mc sampling and plot

using Plots, Distributions, Optim

f(x) = (pdf.(Normal(-1, 1), x) + pdf.(Normal(1, 0.5), x)) / 2
x = [-4:.1:4;]
y = f(x)

plot(x, y)


function mcsampling(n)
    f(x) = -(pdf.(Normal(-1, 1), x) + pdf.(Normal(1, 0.5), x)) / 2
    opt = optimize(f, -4, 4)
    X = -opt.minimum*1.001
    res = zeros(n)
    t = 1 # counter
    g(x) = (pdf.(Normal(-1, 1), x) + pdf.(Normal(1, 0.5), x)) / 2

    xtmp = rand(Uniform(-4, 4), n) # axis x
    ytmp = rand(Uniform(0, X), n)
    dens = g(xtmp)
    colour = map(i -> ytmp[i] < dens[i] ? 1 : 7., 1:n)
    res = [xtmp ytmp dens colour]
    return res
    # return colour
end;

smp = mcsampling(1000)

histogram(smp[:,2], color = 9)

plot(x, y, label = "targe distribution")
scatter!(smp[smp[:,2] .< smp[:,3],1], smp[smp[:,2] .< smp[:,3],2], markercolor = 1,　label = "accept")
scatter!(smp[smp[:,2] .> smp[:,3],1], smp[smp[:,2] .> smp[:,3],2], markercolor = 2,　label = "reject")

savefig("test.png")

# gif animation

plot(x, y, label = "")
# Need to install `ffmpeg` before use @ gif macro.
anim = @gif for i in 1:100
    scatter!([smp[i,1]], [smp[i,2]], markercolor = smp[i,2] > smp[i,3] ? "red" : "blue",　label = "")
end

anim
gif(anim, "test2.gif", fps = 30) # dose not work
