# Constructors and types

# Core
AbstractArray{Float32,3} # type, dims
Core.Array <: Core.AbstractArray
# base
A1 = Base.AbstractVector{Int32} # type, dim = 1
A2 = Base.AbstractMatrix{Float64} # is equal to AbstractArray{T, 2}
Base.AbstractMatrix{Float16}

# Core.Arrayがベーシックそう
# Array{T,N}{undef, dims}
Array{Float64,2}(undef, 3, 4) # 2次元で，一次元目は大きさ3，2次元目は大きさ4
B1 = Array{Union{Nothing,Int},2}(nothing, 3, 4) # Nothing型かInt型のどちらかを受け付ける。
B1[1, 1] = 2
B2 = Array{Nothing,2}(nothing, 3, 4)
B2[1, 1] = 2 # これはダメ

# undefInitializer
UndefInitializer() # returns "array initializer with undefined values", which is Type
Array{Float64,2}(UndefInitializer(), 3, 3)
typeof(undef) # is undefInitializer, which is Alias for UndefInitializer
typeof(UndefInitializer())# is UndefInitializer

# How to create Array
[2; 2] == [1, 2] # !?

[1 2 3] # 2 dims 1 row array
[1, 2, 3] # 1 dims 1 col array
Vector{Int64}(undef, 3) # 1 dim 1 col array
[1 3 3; 2 2 2; 3 3 3] # 3 by 3 array
