using Pkg
Pkg.add("TableReader")

using TableReader

data = readcsv("")
pwd()
cd("/Users/takuizum/local_Documents/R/Vertical Scaling/binary_data")


data = readcsv(
"/Users/takuizum/local_Documents/R/Vertical Scaling/binary_data/e4_j_29_binary.csv")
data
