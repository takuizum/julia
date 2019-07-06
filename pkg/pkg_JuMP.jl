#MILP.jl

using Pkg
Pkg.add("JuMP")
Pkg.add("GLPK")
Pkg.add("SCIP")

# Quick Start Guide
# You also need to include a Julia Pkg which provides an appropriate solver
using JuMP, GLPK

# まずは整数計画法から。連続変数の最適化
# `Model` function create Moldes. The `with_optimizer` syntax is used to specify the optimizer to be used.
# The term `solver` is used as synonym for `optimizer`.
#
m=Model( with_optimizer(GLPK.Optimizer, print_level = 1) )
# Specify different combinations of bounds in Variables section.
@variable(m, x >= 0) # variables and bounds
@variable(m, y >= 0) # variables
# objective function. Firts arg is model object, Second arg is the objective sence `Max` or `Min`.
# Third object is equation(You can use Julia's smart multiplication expression.)
@objective(m, Max, 100 * x + 100 * y ) # objective function
# Adding constraints. `<=` means "less than or equal", `==` means "equal" and `>=` means "greater than or equal"
@constraint(m, x + 2 * y <= 16) # 制約条件
@constraint(m, 3 * x + y <= 18) # 制約条件
# Solved
status = optimize!(m) # ソルバーの実行
termination_status(m)
value(x) # => 4.0
value(y) # => 6.0

# Variables
# 数学的な最適化変数，Julia変数，JuMP変数の3種類が区別される。
model = Model()
# JuMP variables
@variable(model, x[1:2])
@variable(model, y, base_name = "decision variable")
# JuMP変数はJuliaの変数で上書きされない。@variableマクロのなかでのみ上書きされる。
y = 1

## variable bounds
@variable(model, x_free)
@variable(model, x_lower >= 0)
@variable(model, x_upper <= 1)
@variable(model, 2 <= x_interval <= 3)
x_interval
@variable(model, x_fixed == 4)
# nuericリテラルでしか，制約条件は書き下せない。
@variable(model, a <= x)
a = 1 # こうしても，だめ
has_lower_bound(x_free) # boundsが設定されているかどうか
upper_bound(x_upper) # boundsの値
delete_upper_bound(x_interval) # boundsの設定を消す。
has_upper_bound(x_interval)
is_fixed(x_fixed) # fixed valuesを確認する。
fix_value(x_fixed) #
unfix(x_fixed) # 消す。
fix(x_lower, 2; force = true) # こうすることで強制的にbounds条件からfixed条件に変更できる。
