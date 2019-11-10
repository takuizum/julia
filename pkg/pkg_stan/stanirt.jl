using HTTP, DataFrames, CmdStan, Stan, RCall


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
data = first(data, 3000)
data = convert(Matrix{Int64}, data)

function read_git_stan(URL::String)
    res = HTTP.get(URL)
    code = join(readlines(IOBuffer(res.body), keep = true))
    println("----------- Reading Stan Code -----------")
    println(code)
    println("-----------        END        -----------")
    return code
end

# Sampling
code = read_git_stan(
    "https://raw.githubusercontent.com/takuizum/Rstan/master/src/jml.stan"
)
list = Dict(["N" => size(data, 1), "M" => size(data, 2), "y" => data])
mod = Stanmodel(name = "IRT2PL", model = code)
@time rc, sim, cnames = stan(mod, list);

# Check trace plot
using StatsPlots
plot(sim[:,:"a.15",:])

# EAP estimate
eap = mean(sim, dim = 1)
summarize(sim)


# Marginal Model
code = read_git_stan(
    "https://raw.githubusercontent.com/takuizum/Rstan/master/src/mml_em.stan"
)
list = Dict(["N" => size(data, 1), "J" => size(data, 2), "y" => data, "M" => 21])
mod = Stanmodel(name = "IRT_Marginal", model = code)
@time rc, sim, cnames = stan(mod, list);

# Check trace plot
using StatsPlots
plot(sim[:,:"a.15",:])

# EAP estimate
eap = mean(sim, dim = 1)
summarize(sim)

CmdStan.Variational()
