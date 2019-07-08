using JuMP, GLPK
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
