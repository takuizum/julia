# DataFrames
using DataFrames
using Random, RDatasets
# How to create DF
Random.seed!(0204)
df = DataFrame(A = 1:4, B = ["M", "F", "F", "M"], C = randn(4));
df

df.A
df[:A] # is deprecated
# use this one
# どうやらこの!記法はVer1.2からのものらしい。Ver1.1.1では使用できない表記法である。
df[!,:A]
df[!,firstcolumn] # ?

names(df)

# Constructing Column by Column
df = DataFrame()
df.A = 1:10
df[!, :B] = 11:20
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
push!(df, Dict(:B => "F", :A => 3, :C => 1.0))
# 余計なKeyがあってもOK
# ただゆくゆくは廃止される機能なようである。

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
# colum
@show df |> names
df[!, [1, 5]] == df[:, [:SepalLength, :Species]] # subset multiple columns
df[!, [:Species]] |> typeof # returns DataFrame
df[!, :Species] |> typeof # returns vector
# Regular Expression match
df[!, r"S"]  # dplyr::contains()に近い働き
# select row
df[df.SepalWidth .> 3, :]
df[df.Species .== "setosa", :] # '' ≠ ""
# Multipe conditions
df[(df.PetalLength .> 0) .& (5 .< df.SepalLength .< 6), :]

# Summarise
describe(df)
using Statistics
mean(df[!,:SepalWidth])

# aggregate (colimn wise operations)
df = DataFrame(A = 1:4, B = 4.0:-1.0:1.0)
aggregate(df, [sum, prod, mean, length])

# sorting
sort!(df)

# group_by
groupby(df, :A)

# eachcol
# 列単位での処理をまとめて行うときに便利。
collect(eachcol(df, true))
sum.(eachcol(df)) # equivalent to colsums


# Read and Write CSV
# Write
using CSV
df = DataFrame(A = 1:2:1000, B = repeat(1:10, inner=50), C = 1:500)
dir = pwd()*"\\Documents\\"
CSV.write(dir*"TestDF.csv", df)

using TableReader # CSV.read()でも可
readcsv(dir*"TestDF.csv")

# Joins
#
# join
# join(df1, df2, ...)
people = DataFrame(ID = [20, 40], Name = ["John Doe", "Jane Doe"])
jobs = DataFrame(ID = [20, 40], Job = ["Lawyer", "Doctor"])
join(people, jobs, on = :ID)

jobs = DataFrame(ID = [20, 60], Job = ["Lawyer", "Astronaut"])
# left_join
# 一致したものは値を代入し，不一致はmissingを当てはめる。欠測させるのはdf2
join(people, jobs, on = :ID, kind = :left)

# right_join
# 一致したものは値を代入し，不一致はmissingを当てはめる。欠測させるのはdf1
join(people, jobs, on = :ID, kind = :right)

# outer_join
# 一致しないものはとりあえず欠測とし，df1とdf2の両方のデータを完全に保持して結合する。
join(people, jobs, on = :ID, kind = :outer)

# inner_join
# 一致したものだけを残し，df1とdf2で一致しないものはdropさせる。
join(people, jobs, on = :ID, kind = :inner)

# anti_join
# 完全一致したものを，df1の情報だけ残す。結合というよりもマッチングに近い。

# semi_join
# 一致しなかったものを，やはりdf1の情報だけを残す。

# cross_join
