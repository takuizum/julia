# DataFrames
using DataFrames, RDatasets, Random

# How to create DF
Random.seed!(0204)
df = DataFrame(A = 1:4, B = ["M", "F", "F", "M"], C = randn(4));
df

df.A
df[:A] # is deprecated
# use this one
# どうやらこの!記法はVer1.2からのものらしい。Ver1.1.1では使用できない表記法である。
df[!,:A]
df[!,1] # ?

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
# keyを使用しないjoin
join(people, jobs, kind = :cross, makeunique = true)

# Match columns which has different name.
# この例では`ID`と`IDNew`ということなる名前の列をマッチさせたい。
# `left => right`か`tupple`記法が用いられる。
a = DataFrame(ID = [20, 40], Name = ["John Doe", "Jane Doe"])
b = DataFrame(IDNew = [20, 40], Job = ["Lawyer", "Doctor"])
join(a, b, on = :ID => :IDNew, kind = :inner)
join(a, b, on = (:ID, :IDNew), kind = :inner)

# multiple columns, which has different name each other, matching
a = DataFrame(City = ["Amsterdam", "London", "London", "New York", "New York"],
                     Job = ["Lawyer", "Lawyer", "Lawyer", "Doctor", "Doctor"],
                     Category = [1, 2, 3, 4, 5])
b = DataFrame(Location = ["Amsterdam", "London", "London", "New York", "New York"],
                     Work = ["Lawyer", "Lawyer", "Lawyer", "Doctor", "Doctor"],
                     Name = ["a", "b", "c", "d", "e"])
join(a, b, on = [(:City, :Location), (:Job, :Work)])
# マッチさせたもの以外で，データフレームのどの1が重複していなかったのかを確認できる。
# `validate`引数はマージしたいDF2種類をチェックするかどうか。
join(a, b, on = [(:City, :Location), (:Job, :Work)], validate=(true, true))

# Using `indicator`
# マージしたあとにマージした列がdf1とdf2のどちらに（あるいは両方）に入っているのかを確認できる。

a = DataFrame(ID = [20, 40], Name = ["John Doe", "Jane Doe"])
b = DataFrame(ID = [20, 60], Job = ["Lawyer", "Doctor"])
join(a, b, on=:ID, validate=(true, true), indicator=:source, kind=:outer)


# The Split-Apply-Combine Strategy

using RDatasets
iris = RDatasets.dataset("datasets", "iris")

# `groupby` = `by`が使える。
# byはgroupbyとmapを組み合わせたみたいな関数。
# by(DF, keys, cols => f(), sort = Bool)
by(iris, :Species, mean = :SepalWidth => mean)
# groupbyとcombineで同じことができる。
combine(:SepalLength => mean, groupby(iris, :Species))
# 複数列を使って新しい列にsummarizeするのはすこしややこしい記法
# 第3引数の構造は[取り出したい列名のsymbol] => x(一時的なDFとして定義) -> hoge = fuga(x.sym1)/piyo(x.sym2)
by(iris, :Species, [:PetalLength, :SepalLength] => x -> (a=mean(x.PetalLength)/mean(x.SepalLength),b=sum(x.PetalLength)))

using StatsFuns
function DFby(df::AbstractDataFrame)
   by(df, :Species, μ = :SepalWidth => mean, σ² = :SepalLength => var)
end
# byとdoを組み合わせることもできるが，パフォーマンスは悪いので，これは避けるべき
function DFdo(df::AbstractDataFrame)
   by(df, :Species) do df
               (m = mean(df.PetalLength), s² = var(df.PetalLength))
           end
        end

using BenchmarkTools
@benchmark DFby(iris)
@benchmark DFdo(iris)

# aggregate
# aggregateを使えば，もう少しだけシンプルに記述ができる。
# keyはIntでも可
@show aggregate(iris, :Species, [length, mean])
@show aggregate(iris, 5, [length, mean])


# Reshaping and Pivoting Data
iris = RDatasets.dataset("datasets", "iris")

# stack
# wide data frames to long format
# is equivalent to `pivot_longer`
stack(iris, [:SepalLength, :SepalWidth, :PetalLength, :PetalWidth], variable_name = :MeasureType, value_name = :MeasureValue)
# Third optional = id columns
# Drop columns which is not specified
stack(iris, [:SepalWidth, :SepalLength])
stack(iris, [:SepalWidth, :SepalLength], :Species)

# melt
# altarnative reshape function
# This function prefer id columns than measure_vars
melt(iris, :Species, variable_name = :MeasureType, value_name = :MeasureValue)

# unstack
# Convert long formated data frame to wide format. `pivot_wider`, in R, is similar to this function.
# first arg = DF, second arg = row key, third arg = col key, fourth arg = velue col
long_df = melt(iris, :Species, variable_name = :MeasureType, value_name = :MeasureValue)
unstack(long_df, :Species, :MeasureType, :MeasureValue)

# `stack` and `stackdf`
stack(iris)==stackdf(iris)

# Sorting
# Add `!` command for sorting and inserting simultaneously.
# Set `rev = true` to reverse the order.
# The first and second passed argument, symbols and logicals, can be specified as vector.
sort(iris)
sort!(iris)
first(iris, 7)
sort!(iris, (:Species, :PetalLength), rev=(true, false))

# Handling Categorical Data

# String vector
v = ["Group A", "Group A", "Group A", "Group B", "Group B", "Group B"]
# A type of CategoricalArray permit missing value and convert scring vector to CategoricalArrays
using CategoricalArrays
CategoricalArray(v)
# Missing value is not recognized as level.
CategoricalVector([missing, 'A', 'A', 'B', missing]) |> levels
# level! function allows changing the order of appearance of the levels.
v = CategoricalVector([missing, 'A', 'A', 'B', missing]) 
v |> x->levels!(x, ['B', 'A']) |> levels

# Missing Data
typeof(missing)
x = [1, 2, missing]
typeof(x) # type of ~~
eltype(x) # element type of ~~
# Exclude missing data
skipmissing(x)
x |> sum
x |> skipmissing |> sum
# replace missing value
coalesce.(x, 999)
# Drop missing records (for Data Frame only)
df = DataFrame(i = 1:5,
               x = [missing, 4, missing, 2, 1],
               y = [missing, missing, "c", "d", "e"]
               )
dropmissing(df)
dropmissing(df, :y)
# `dropmissing` keeps the union type if set the `disallowmissing` option to `false`
dropmissing(df, disallowmissing = false)

# Using `Missings` pkg
using Missings
Missings.replace(x, 999) |> collect

# Determine type without missing data
nonmissingtype(eltype(x))

# Create missing data vector
missings(10)
missings(2, 3)
missings(Int, 1, 2)

# Data manipulation frameworks
# Handle DataFrames in Julia as if using `dplyr` in R
import Pkg; Pkg.add("DataFramesMeta")
using DataFramesMeta

df = DataFrame(name=["John", "Sally", "Roger"],
               age=[54., 34., 79.],
               children=[0, 2, 4])

@linq df |> 
   # `filter`
   where(:age .> 40) |>
   # `select` & `mutate` 
   select(NofChildren = :children, :name)