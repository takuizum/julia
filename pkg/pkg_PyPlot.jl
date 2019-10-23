using Pkg
Pkg.build("PyPlot") # false
Pkg.add("PyPlot")
Pkg.build("Conda") # false
Pkg.add("Conda")
using Conda
Conda.list()
# juliaフォルダ内のcondaにインストール
Conda.add("matplotlib")
Conda.add("numpy")
Conda.add("scipy")

Pkg.add("PyCall")
Pkg.build("PyCall")
using PyCall
pyimport_conda("matplotlib")

PyCall.libpython
ENV["PYTHON"] = "/Users/takuizum/.julia/conda/3/bin/python"
ENV["PATH"]