# GLM package
import Pkg; Pkg.add("GLM")
using GLM, RDatasets, TableReader 

# Convert DataFrame encoding to UTF-8 from S-JIS.
data = readcsv("/Users/takuizum/local_Documents/julia/data/R_Multivariate Analysis0726/第10章/自転車データ.csv")

# Saturation Model
fullmodel = glm(@formula(度数~年代*性別*メーカー), data, Poisson())
fullmodel

# Indipendent Model
idmodel = glm(@formula(度数~年代+性別+メーカー), data, Poisson())
idmodel

bestmodel = glm(@formula( 度数 ~ 年代+性別+メーカー + (年代*性別) + (年代*メーカー) ), data, Poisson())