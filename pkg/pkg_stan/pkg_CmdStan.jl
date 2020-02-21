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

using CmdStan#, Stan
show(ENV)
# Stan.set_cmdstan_home!("C:\\Users\\bc0089985\\cmdstan\\")
set_cmdstan_home!("/Users/takuizum/cmdstan")
set_cmdstan_home!("C://Users/bc0089985/cmdstan")
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

rc, sim, nm = CmdStan.stan(stanmodel, dat)

using StatsPlots, DataFrames
describe(sim)
StatsPlots.density(sim[:,8,:]) # Good!

# Error Message is as below -------------------------------------
# An error occurred while compiling the Stan program.
# Please check your Stan program in variable 'bernoulli' and the contents of C:/Users/bc0089985/Documents/GitHub/julia/tmp/bernoulli.exe_build.log.
# Note that Stan does not handle blanks in path names.

# 2020-02-21
# thinの設定でワーニングが起きているので削除。
# Defaultの1だとワーニング。しかし1よりも大きくしてもだめ。
# しかもplotが使えなくなっている。->設定を変更して，機能することを確認。

# 2020/02/05
# Mac環境下似て，Xcodeのバージョンを上げると，stan()実行時にエラーが起きる。
# cmdstanディレクトリに行き，rebuildすることで解消。

# 2020/02/06
# Windows環境下でエラー。少なくともrstanで動かない。どうやらインストールされているバージョンが依存関係のあるパッケージのバージョンと食い違っていることが原因のようだ。
# 少なくともjuliaではCmdStanが正常に動いてくれている。やはりRstanが悪いらしい。クリーンインストールを試みる。->すくなくともデモコードは動いたので，どうやら自分の書いたstanコードが悪いらしいorz


# Stan に移行
using StanSample, StanBase, ArgCheck
using Stan
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

sm = SampleModel("bernoulli", bernoullimodel;
  method = StanSample.Sample(save_warmup=true,
    adapt = StanSample.Adapt(delta = 0.85)),
    # tmpdir = "tmp",
);
dat = [Dict("N" => 10, "y" => [0, 1, 0, 1, 0, 0, 0, 0, 0, 1])]

rc = stan_sample(stanmodel, data = dat);

if success(rc)
  samples = read_samples(sm);
end
