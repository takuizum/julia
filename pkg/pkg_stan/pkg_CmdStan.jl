# run below code in Shell.
# 1
# git clone https://github.com/stan-dev/cmdstan.git --recursive
# 2
# Setting `make` utility program , for example, Rtools or MSYS2. and through a path to C++ compiler.
# 3
# Move to cmdstan directory and build cmdstan by entering `make build -j4
# 4
# Useful reference
# https://nbviewer.jupyter.org/gist/genkuroki/57a301d715ac754a583f7e711f904f31




using Pkg; Pkg.add("CmdStan") # take several minutes.

Pkg.add("Mamba") # こちらもひつよう？

ENV["CMDSTAN_HOME"] = "C:\\Users\\bc0089985\\cmdstan\\"
ENV["CMDSTAN_HOME"] = "/Users/takuizum/cmdstan"

using CmdStan
show(ENV)
# Stan.set_cmdstan_home!("C:\\Users\\bc0089985\\cmdstan\\")
Stan.set_cmdstan_home!("/Users/takuizum/cmdstan")
# ENV["JULIA_CMDSTAN_HOME"] = "C:\\Users\\bc0089985\\cmdstan\\"
versioninfo()

# Example
bernoullimodel = "
data {
  int<lower=0> N;
  int<lower=0,upper=1> y[N];
}
parameters {
  real<lower=0,upper=1> theta;
}
model {
  theta ~ beta(1,1);
  y ~ bernoulli(theta);
}

"

stanmodel = Stanmodel(num_samples=1200, thin = 4, model=bernoullimodel, name = "bernoulli")
stanmodel |> display
dat = [Dict("N" => 10, "y" => [0, 1, 0, 1, 0, 0, 0, 0, 0, 1])]

rc, sim = CmdStan.stan(stanmodel, dat)

# Error Message is as below -------------------------------------
# An error occurred while compiling the Stan program.
# Please check your Stan program in variable 'bernoulli' and the contents of C:/Users/bc0089985/Documents/GitHub/julia/tmp/bernoulli.exe_build.log.
# Note that Stan does not handle blanks in path names.

describe(sim)
plot(sim) # Good!
