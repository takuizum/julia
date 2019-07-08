# Julia for SCIP optimizer
# https://github.com/SCIP-Interfaces/SCIP.jl
# 将来的には`MathOptInterface`に統一されるみたい。
using Pkg
Pkg.add("SCIP")

using SCIP, MOI
