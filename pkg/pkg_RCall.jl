# set up
using Pkg
Pkg.add "RCall"
Pkg.build("RCall")
show(ENV)

ENV["R_HOME"]="C:/Users/bc0089985/Documents/R/R-3.6.0/bin"


using RCall
@rlibrary irtfun2
res = estip2(data, fc = 3)
res
@rput res
# REPLで$を入力すると，R mode になる
@rget para
@rget se

se
