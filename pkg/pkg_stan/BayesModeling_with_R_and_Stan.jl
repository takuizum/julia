# Sample data and codes
# https://github.com/logics-of-blue/book-r-stan-bayesian-model-intro/tree/master/book-data

###################
# Basic operation #
###################

# Create Matrix
matrix_1 = reshape([1:1:10;], 2, 5)

# named array
using NamedArrays
matrix_2 = NamedArray(matrix_1)
setnames!(matrix_2, ["Row1", "Row2"], 1)
setnames!(matrix_2, map(x -> *("Col", x), string.([1:1:5;])), 2)
@show matrix_2

size(matrix_2)


#######################################
# Stan Practice 1 : Estimate μ and σ. #
#######################################

# read sample data
using TableReader, HTTP, DataFrames, CmdStan, Stan
res = HTTP.get("https://raw.githubusercontent.com/logics-of-blue/book-r-stan-bayesian-model-intro/master/book-data/2-4-1-beer-sales-1.csv")
file_beer_sales_1 = readcsv(IOBuffer(res.body))
data_list = [Dict("sales" => vec(convert(Matrix, file_beer_sales_1)), "N" => size(file_beer_sales_1, 1))]
# read code
Code = HTTP.get("https://raw.githubusercontent.com/logics-of-blue/book-r-stan-bayesian-model-intro/master/book-data/2-4-1-calc-mean-variance.stan")
stan_code = Code.body |> IOBuffer |> x -> readlines(x, keep = true) |> join

stan_model = Stanmodel(name = "beer_data", model = stan_code, thin = 4, nchains = 4,
                       num_warmup = 1000, num_samples = 2000, random = CmdStan.Random(1))
rc, chns, cnames = CmdStan.stan(stan_model, data_list)

# HPD
MCMCChains.hpd(chns) # Good

# plot
using StatsPlots
plot(chns) # Good!
plot(chns, [:mu]) # display paticular parameters.

#
density(chns, :mu)

histogram(chns)

# extract data
using Mamba
chns.value
Mamba.plot(chns) # Error!
CmdStan.convert_a3d(chns, cnames, Val(:mambachains))

chns.info
chns.logevidence
chns.name_map
mcmc_sample = chns.value # 3D array

# Dim (Iter, param?, chains)
# -> chack by `chns.name_map`
size(mcmc_sample)
mcmc_sample[:,8,:]


###################################################
# Stan practice 2 : Posterior Predictive Checking #
###################################################

using TableReader, HTTP, DataFrames

res = HTTP.get("https://raw.githubusercontent.com/logics-of-blue/book-r-stan-bayesian-model-intro/master/book-data/2-5-1-animal-num.csv")
animal_num = res.body |> IOBuffer |> readcsv

Code1 = HTTP.get("https://raw.githubusercontent.com/logics-of-blue/book-r-stan-bayesian-model-intro/master/book-data/2-5-1-normal-dist.stan")
code_normal = Code1.body |> IOBuffer |> x->readlines(x, keep = true) |> join
# Define stan code reading function
read_git_stan = function(URL::String)
    res = HTTP.get(URL)
    code = join(readlines(IOBuffer(res.body), keep = true))
    println("----------- Reading Stan Code -----------")
    println(code)
    println("-----------        END        -----------")
    return code
end

code_poisson = read_git_stan("https://raw.githubusercontent.com/logics-of-blue/book-r-stan-bayesian-model-intro/master/book-data/2-5-2-poisson-dist.stan")
@show code_poisson

# must be string (not symbol)
data_dict = [Dict("animal_num" => vec(convert(Matrix, animal_num)), "N" => size(animal_num, 1) )]

using Stan, CmdStan

# model
mod_normal = Stanmodel(name = "normal_model", model = code_normal, random = CmdStan.Random(1))
mod_poisson = Stanmodel(name = "poisson_model", model = code_poisson, random = CmdStan.Random(1))

# inference
rc_normal, sim_normal, cnames_normal = stan(mod_normal, data_dict)
# Error occurs in normal model.
# Informational Message: The current Metropolis proposal is about to be rejected because of the following issue:
# Exception: normal_lpdf: Location parameter is inf, but must be finite!  (in '/Users/takuizum/local_Documents/julia/tmp/normal_model.stan' at line 11)
# If this warning occurs sporadically, such as for highly constrained variable types like covariance matrices, then the sampler is fine,
# but if this warning occurs often then your model may be either severely ill-conditioned or misspecified.

rc_poisson, sim_poisson, cnames_poisson = stan(mod_poisson, data_dict)

using StatsPlots

index = map(x->match(r"pred", x), cnames_normal)
idx = [1:1:size(index, 1);][index .!= nothing]
sim_normal[:,idx,:]

# observed histogram
@df animal_num histogram(:animal_num)

# simulated histogram droped by normal model
sim_normal[:,100,:]
histogram(sim_normal[:,100:104,1], layout = 4)

CmdStan.convert_a3d(sim_normal, cnames)
