# Sample data and codes
# https://github.com/logics-of-blue/book-r-stan-bayesian-model-intro/tree/master/book-data

# Basic operation

# Create Matrix
matrix_1 = reshape([1:1:10;], 2, 5)

# named array
using NamedArrays
matrix_2 = NamedArray(matrix_1)
setnames!(matrix_2, ["Row1", "Row2"], 1)
setnames!(matrix_2, map(x -> *("Col", x), string.([1:1:5;])), 2)
@show matrix_2

size(matrix_2)

# read sample data
using TableReader, HTTP, DataFrames
res = HTTP.get("https://raw.githubusercontent.com/logics-of-blue/book-r-stan-bayesian-model-intro/master/book-data/2-4-1-beer-sales-1.csv")
file_beer_sales_1 = readcsv(IOBuffer(res.body))
data_list = [Dict("sales" => vec(convert(Array, file_beer_sales_1)), "N" => size(file_beer_sales_1, 1))]
# read code
Code = HTTP.get("https://raw.githubusercontent.com/logics-of-blue/book-r-stan-bayesian-model-intro/master/book-data/2-4-1-calc-mean-variance.stan")
stan_code = Code.body |> IOBuffer |> x -> readlines(x, keep = true) |> join

stan_model = Stanmodel(name = "beer_data", model = stan_code, thin = 1, nchains = 1,
                       num_warmup = 1000, num_samples = 2000, random = CmdStan.Random(1))
rc, chns, cnames = CmdStan.stan(stan_model, data_list)
