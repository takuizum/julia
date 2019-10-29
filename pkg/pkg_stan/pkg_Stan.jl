# run below code in Shell.
# git clone https://github.com/stan-dev/cmdstan.git --recursive

using Pkg; Pkg.add("Stan") # take several minutes.
Pkg.add("Mamba") # こちらもひつよう？

ENV["CMDSTAN_HOME"] = "C:\\Users\\bc0089985\\cmdstan\\cmdstan-2.21.0\\"
ENV["CMDSTAN_HOME"] = "/Users/takuizum/cmdstan/"
using Stan, Mamba, CmdStan
show(ENV)
# Stan.set_cmdstan_home!("C:\\Users\\bc0089985\\cmdstan\\")
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

stanmodel = CmdStan.Stanmodel(num_samples=1200, thin=2, model=bernoullimodel)
stanmodel |> display
dat = [Dict("N" => 10, "y" => [0, 1, 0, 1, 0, 0, 0, 0, 0, 1])]

rc, sim = CmdStan.stan(stanmodel, dat)
