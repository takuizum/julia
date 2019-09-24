# DataFrames
using DataFrames
using Random, RDatasets
# How to create DF
Random.seed!(0204)
df = DataFrame(A = 1:4, B = ["M", "F", "F", "M"], C = randn(4));
df

df.A
df[:A]
df[!,firstcolumn]

names(df)

# Constructing Column by Column
df = DataFrame()
df.A = 1:10
df[:B] = 11:20
df

# size
size(df)
size(df, 1)
size(df, 2)
nrow(df)
ncol(df)

# Constructing Row by Row
df = DataFrame(A = Int[], B = String[])
push!(df, (1, "M"))
push!(df, [2, "N"])
# DictのKeyがマッチしていれば，DataFrameの行追加に適用できる。
push!(df, Dict(:B => "F", :A => 3))
push!(df, Dict(:B => "F", :A => 3, :C => 1.0)) # 余計なKeyがあってもOK

# Working with Data Frames
df = RDatasets.dataset("datasets", "iris")
first(df, 10)
last(df, 1)

# DF, contains Missing
DataFrame(a = 1:2, b = [1.0, missing],　
          c = categorical('a':'b'), d = [1//2, missing])

# Taking a Subset of DF
# row
df[1:3, :]
# column
df[:, 1:2] == df[:, [:A, :B]]
df[:, [:A]] |> typeof # returns DataFrame
df[:, :A] |> typeof # returns vector
# select row
df[df.A .> 500, :]
df[df.A .== 1, :]

# Summarise
df = DataFrame(A = 1:4, B = ["M", "F", "F", "M"])
describe(df)

# aggregate (colimn wise operations)
df = DataFrame(A = 1:4, B = 4.0:-1.0:1.0)
aggregate(df, [sum, prod, mean, length])

# Read and Write CSV
# Write
using CSV
df = DataFrame(A = 1:2:1000, B = repeat(1:10, inner=50), C = 1:500)
dir = pwd()*"\\Documents\\"
CSV.write(dir*"TestDF.csv", df)

using TableReader # CSV.read()でも可
readcsv(dir*"TestDF.csv")
