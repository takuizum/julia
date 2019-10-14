# Multilevel Models
import Pkg; Pkg.add("MixedModels")
using MixedModels, RDatasets, TableReader 

# Convert DataFrame encoding to UTF-8 from S-JIS.
data = readcsv("/Users/takuizum/local_Documents/julia/data/井の中の蛙.csv")
data |> x -> first(x, 10)

# Unconditional intercept model
mod1 = LinearMixedModel(@formula(学業的自己概念~テスト得点+(1|学級)), data)
fit(MixedModel, @formula(学業的自己概念~テスト得点+(1|学級)), data)

# Unconditonal slope model




