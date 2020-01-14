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


using  GLM, Random, Distributions, DataFrames

Random.seed!(1234)
X = rand(Poisson(10), 200)
scl = [minimum(X):1:maximum(X);]
freq = map(j -> count(i -> i == j, X), scl)
df = DataFrame(y = freq, x = scl)

glm(@formula(y ~ x+x^2), df, Poisson(), LogLink())

# 動く
function shorthand1(df)
    glm(@formula(y ~ x+x^2), df, Poisson(), LogLink())
end
shorthand1(df)

# 動かない
function shorthand2(df)
    fm = eval(Meta.parse("@formula(y ~ x+x^2)"))
    glm(fm, df, Poisson(), LogLink())
end
shorthand2(df)

#グローバルなら動く
glm(eval(Meta.parse("@formula(y ~ x+x^2)")), df, Poisson(), LogLink())
