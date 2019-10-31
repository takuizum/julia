# Sample data and codes
# https://github.com/logics-of-blue/book-r-stan-bayesian-model-intro/tree/master/book-data

# Basic operation

# Create Matrix
matrix_1 = reshape([1:1:10;], 2, 5)

# named array
using NamedArrays
matrix_2 = NamedArray(matrix_1)
setnames!(matrix_2, ["Row1", "Row2"], 1)
setnames!(matrix_2, map(x -> *("Col", x), string.([1:1:5;])), 2)
@show matrix_2

size(matrix_2)
