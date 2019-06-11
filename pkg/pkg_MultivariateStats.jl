# Multivariate Stats
# See https://multivariatestatsjl.readthedocs.io/en/latest/index.html
using MultivariateStats
using TableReader
using DataFrames

data = readcsv(
"/Users/takuizum/OneDrive/Documents/09_seminar/FA/DL02126/R_code/dat/6科目学力(量的).csv"
)

head(data)
data2 = convert(Array{Float64,2}, data)
import MultivariateStats
res = MultivariateStats.fit(FactorAnalysis, data2; maxoutdim = 4, mean = 0)
res = fit(PPCA, data2; maxoutdim = 2)
