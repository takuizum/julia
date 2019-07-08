# rand
using Random
Random.seed!(0204) # set seed
rand()
rand(1:10)
rand((1,2,4,5)) # Rでいうsample関数に近い
rand("Julia")
# randn
# Standard Normal random variable generator
randn(10)
# randstring
randstring('a':'d', 3)
Int128[2^19937]
# randsubseq
randsubseq(1:6, 0.333)
