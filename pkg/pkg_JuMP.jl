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

## Variables containers
# より複雑なデータ構造に対応した制約を課すために，containersを使う。
Array{Int64, 2}(undef, 3, 3)

# MOI = MathOptInterface
# ----- Variable names -----
# JuMP の Modelに指定する変数にはnames attributeを与えることができる。
#`name()`  # Method
# `set_names()` # Method
# ` variable_by_name` # Function
# 基本的な用途では`@variable`記法で問題ない？

model = Model()
@variable(model, x)
variable_by_name(model, "x") # 変数指定の際はかならずStringに。
# 複数の変数に同一の名前を与えるとエラーになるので要注意。
variable_by_name(model, "y")　# 指定した名前の変数がなければ，なにも返ってこない。
@variable(model, u[1:2])
variable_by_name(model, "u[2]") # container の場合はこんな感じに指定する。

# Variable containers
# 基本的には一般的なArray表記とおなじか。
# 外部で作ってきたArrayは使えない？
## Array
@variable(model, x[1:2, 1:2])
@variable(model, x[i=1:2, j=1:2] >= 2i + j) # 配置に依存するboundsの設定方法
## DenseAxisArray
# インデクスとして任意の文字が使用できるのが違い
@variable(model, x[1:2, [:A,:B]]) # DenseAxis
## SparseAxisArray
### 長方形以外の形で配列を組んで，指定するとき。
@variable(model, x[i=1:2, j=i:2])
@variable(model, x[i=1:4; mod(i, 2)==0])
## Forcing the container type
# Arrayの形とかを予め設定しておいてから，containerにするときに便利
A = 1:2
@variable(model, x[A])
# この指定方法だとDenseArray以外に通常のArrayとしても保持してしまう。
@variable(model, y[A], container = Array)
## Integrarlity shortcuts
# 変数が整数であることの制約を加えるためには`Bin`を利用すればよい。
@variable(model, x, Bin)
@variable(model, x, binary=true) # あるいは変数宣言の時でもOK
unset_binary(x) # 制約をはずす。
## Semidefinite variables (半正定値行列変数)
@variable(model, x[1:2, 1:2], PSD)
@variable(model, x[1:2, 1:2], Symmetric)
## Anonymous JuMP variables
# マクロ呼び出しから変数をdropする形で，Anonymous変数は得られる。
model = Model()
x = @variable(model, [i=1:2], base_name="x", lower_bound=i, integer=true)
model[:x] = x # modelの中にxを保存。
## User-defined container


# ----- Expressions -----
## affinem quadratic, nonlinearの3種類のexpression typesをもつ。

## Affin Expressions
# オススメ記法1: expression macroをつかってaffine表現を与える。
model = Model(with_optimizer(GLPK.Optimizer))
@variable(model, x)
@variable(model, y)
ex = @expression(model, 2x + y - 1)
@objective(model, Min, 2 * ex - 1)
objective_function(model)
# optimize!(model)
# value(x)
# value(y)

# オススメ記法2: Operator overloading
# ただし計算が遅くなることがある。
model = Model()
@variable(model, x)
@variable(model, y)
ex = 2x + y - 1

# オススメ記法3: AffExpr()を使ったconstructors
model = Model()
@variable(model, x)
@variable(model, y)
ex = AffExpr(-1.0, x => 2.0, y => 1.0) # `変数名 => 係数`

# オススメ記法4: add_to_expression!()を使ったconstructors
model = Model()
@variable(model, x)
@variable(model, y)
ex = AffExpr(-1.0)
add_to_expression!(ex, 2.0, x) # 加える先の変数, 係数, 変数名
add_to_expression!(ex, 1.0, y)

## Quadratic Expressions
# Affinの時と一緒だが二次の項までOK
model = Model()
@variable(model, x)
@variable(model, y)
ex = @expression(model, x^2 + 2 * x * y + y^2 + x + y - 1)

## Nonlinear Modeling
# http://www.juliaopt.org/JuMP.jl/v0.19.2/nlp/#Nonlinear-Modeling-1

# ----- Objective -----
# 線形モデルにおける目的関数を定義する。
# 基本は `@objective(Model, sense, func)`
# senseは`Max`か`Min`
# funcは目的関数
@objective(model, Max, 2x - 1) # 基本的なマクロを使った書き方。
# sense単体を指定するときは`MOI.MIN_SENSE`
sense = MOI.MIN_SENSE
@objective(model, sense, x^2 - 2x + 1)


# ----- Constraints -----

## Constraint containers
# Arrys
@constraint(model, con[i = 1:3], i * x <= i + 1)
# DenseAxisArrays
@constraint(model, con[i = 1:2, j = 2:3], i * x <= j + 1)
# Sparse Axis Arrays
@constraint(model, con[i = 1:2, j = 1:2; i != j], i * x <= j + 1) # 対角成分がない。

## Vectorized constraints
# 行列の積で制約条件を定義できる。（これは使えそう？）
model = Model()
@variable(model, x[i=1:2])
A = [1 2; 3 4];b = [5, 6]
A * x
@constraint(model, con, A * x .== b) # 項目に関する不等式はこうやってやればよさそう。

## Constrainr modifications
model = Model()
@variable(model, x)
@variable(model, const_term)
@constraint(model, con, 2x <= const_term) # 指定の時点ではdummyを入れておいて，後から指定する。
fix(const_term, 1.0)
@constraint(model, con, 2x <= 1)
set_coefficient(con, x, 3) # coefficientを後から変更する
delete(model, con) # constraint deletion

# Accessing constraints from a model
model = Model()
@variable(model, x[i=1:2] >= i, Int)
@constraint(model, x[1] + x[2] <= 1)
list_of_constraint_types(model) # modelのconstraints typeをハックする。
num_constraints(model, VariableRef, MOI.Integer) # the number of constraints
all_constraints(model, VariableRef, MOI.Integer) # all of constraints
num_constraints(model, VariableRef, MOI.GreaterThan{Float64})
all_constraints(model, VariableRef, MOI.GreaterThan{Float64})

# Constructing constraints without adding them to the model
# @マクロを使ってconstraintsを加えていく
@build_constraint(2x >= 1)
