# Multivariate Stats
# See https://multivariatestatsjl.readthedocs.io/en/latest/index.html
using MultivariateStats
using TableReader
using DataFrames

data = readcsv(
"/Users/takuizum/OneDrive/Documents/09_seminar/FA/DL02126/R_code/dat/6科目学力(量的).csv"
)

head(data)
data2 = reinterpret(Float64, Matrix(data))
import MultivariateStats
res = fit(FactorAnalysis, data2; maxoutdim = 2)
res = fit(PPCA, data2; maxoutdim = 2)
