# multi-dimensional arrays

# how to create a col vector

A = [1,2,3,4,5,6]
B = [5
     4
     3
     2
     1]
C = [1;2;3;4;5]
# how to create a matrix
D = [1 2 3;4 5 6;7 8 9] # この書き方の場合は","で区切ってはいけない
E = [
1 2 3
4 5 6
7 8 9
]
# multi-dim array
F = Array{Float64, 3}
G = zeros(Float64, 3, 3, 3)
H = zeros(Int64, 3, 2, 4)

# basic functions
# type
eltype(A)
eltype(E)
E |> eltype
# length(elements)
length(B)
length(D)
# dimension
ndims(A)
ndims(D)
ndims(H)
# size of tuples
size(A)
size(E)
size(G)
size(H, 2)
# a tuple containing the valid indices of A
axes(A)
axes(D)
# a range expressing the valid indices along dimension n
axes(H, 2)
# index(an eddicient iterator for visiting each position A)
eachindex(D)
# ???
stride(H, 2)
strides(B, 1)

# Construction and Initialization
Array{Int64}(undef, 3, 3)
zeros(3,3,3)
ones(4,2,3)
trues(3,2,2)
falses((3,2,4))
# reshape
reshape(A, 2,3)
reshape(D, 9)
reshape(D, length(D)) # 列から順番にreshapeあとの配列にアサインしている
# copy
Z = A
A[2] = 7
A
Z # pythonとおなじで，=は右と左の要素を接続する処理をする
Z = copy(A)
A[2] = 2
A
Z # これならもとのAが変更されてもZには影響しない
# deepcopy
# See also, https://discourse.julialang.org/t/what-is-the-difference-between-copy-and-deepcopy/3918/2
Z = deepcopy(A)
A[2] = 100
A
Z
# similar
# uninitializedな，要素，型が同じ変数を複製する
Y = similar(H)
Y
# reinterpret (型の変換)
reinterpret(Float64, UInt64[1,2,3,4,5,6,7,100])
reinterpret(Int64, Float64[1.1,10.45])
# uniformly random variables
rand(10) # vector
randn(9,3,3) # Array
# Martix
Matrix{Float64}(undef, 3,5)
Matrix{Int128}(undef, 3,5)
# range
# range(start[, stop]; length, stop, step=1)
range(1, 4) # is equivalent to 1:4
X = range(1, 4, step = 0.1)
length(X)
range(1, stop = 50, step = 0.01)
# fill
D
fill!(D, 100)
fill(missing, (2,2,2))
# concatenation:"cat"
cat([1.0, 1.2], [3.3, 4.4]; dims = 2)
vcat([1.0, 1.2], [3, 4])
vcat([1.0 1.2], [3 4])
hcat([1, 2], [3.5, 4.09])
hcat([1 2], [3 4]) # row vector
#
[1;2;3] #vcat
[1 2 3] # hcat
[1 2; 3 4] # hvcat
# The concatenation functions are used so often that they have special syntax
[[1;2];[3, 4]] # col vectorize then concatenation = col vector
[[1 2] [2 4]] # row vecttorize then concatenation without ';' = row vector
[[1 2]; [3 4]] # row vecttorize then concatenation with ';' = 2-dims array
[[1, 2]; [3, 4]] # col vector
# typed array
Float64[1,2,3,4]
Int128[3,4,5,6]
# comprehensions: a general and powerful way to construct arrays
# A = [ F(x,y,...) for x=rx, y=ry, ... ]
x = rand(8)
[0.25*x[i-1] + 0.5*x[i] + 0.25*x[i+1] for i=2:length(x)-1]
