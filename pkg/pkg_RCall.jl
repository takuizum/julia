# set up
using Pkg
# Environment setting
Pkg.add("RCall")
Pkg.build("RCall") # if Julia needs
# LoadError: R cannot be found. Set the "R_HOME" environment variable to re-run Pkg.build("RCall").
ENV["R_HOME"] # missing R ENV
show(ENV)
ENV["R_HOME"]="C:\\Users\\bc0089985\\Documents\\R\\R-3.6.0" # binまでは通さない。
Pkg.build("RCall") # rebuild

using RCall
@rlibrary irtfun2
res = estip2(data, fc = 3)
res
@rput res
# REPLで$を入力すると，R mode になる
@rget para
@rget se

# Basic syntax
rcopy(R"1:5") # get R eval
# input `$` in REPL, then R code can be written in REPL in direct.
# To pass julia variable to R, use `$` before variables
x = 3.0
R"1 + $x" # An inline R expression
# Using macro
x = 10
# put variavles in R env
@rput x
R"r = rnorm(x)"
@rget r # ダイレクトにENVに代入される。
r
# pass julia variables and get its eval.
rcopy(R"1 + $x")
# R_str string macro
R"n = 1 + 1;rnorm(n)" # last eval only.
# multiple lines
R"""
n = 100 + 1
r = rnorm(n)
plot(c(1:n), r, type = "l") # graphic output
"""

for i in 1:10
    @rput i
    R"""
    cat("In R world, iteration time is",i)
    t = i
    """
    @rget t
    println(", but In Julia World ", t)
end

# get data in R env
starwars = reval("starwars")
iris = reval("iris")
iris["Species"]
starwars["name"]
# using R function
rcall(:plot, [1:100;], rand(100), type = "l", ylab = "rand")
rcall(:sum, [1:10;])

# using R package
# @rlibrary macroは非効率なので非推奨？
R"""
library(tidyverse)
ggplot(tibble(x = seq(-4, 4, len = 101), y = dnorm(seq(-4, 4, len = 101))), aes(x = x, y = y)) +
geom_line()
"""
