# learning julia DAY 1

# R でこれまでやってきた事を，juliaでもやりたいっていうのがモチベーション

# パッケージについて
using Pkg # これがないとPkg.addが使えない。
Pkg.add("RDatasets")
using RDatasets
Pkg.add("PyPlot")
using PyPlot
Pkg.add("Gadfly") # plot 用のパッケージらしいが，コンパイラがうまくいかないよう
using Gadfly
Pkg.add("Plots")
using Plots
Pkg.add("GR")


iris = RDatasets.dataset("datasets", "iris")
head(iris)


gr()
plot(randn(100,3))



# なんだかだめみたい
