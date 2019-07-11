using JuMP, GLPK, Random, Distributions, StatsFuns

# generate sample item paraemters

α = rand(LogNormal(-0.5, 0.5), 90)
histogram(α)
β = rand(Normal(0, 1.5), 90)
scatter(α, β)
# 今仮に，前半50項目をA領域，後半40項目をB領域とする

function tif(θ, α, β)
    I = zeros(length(θ))
    for m in 1:length(θ)
        for j in 1:length(α)
            p = logistic(α[j]*(θ[m]-β[j]))
            I[m] += α[j]^2 * p * (1-p)
        end
    end
    return I
end

tif([-4, 0, 4], α, β) # optimize base points
fill(1, 3)'tif([-4, 0, 4], α, β)
tmp = [tif(target_θ[i], α[j], β[j])[1] for i in 1:5, j in 1:90]
fill(1, 90)'tmp

target_θ = [-2:1:2;]
target_TIF = tif(target_θ, α, β) * 30/90
IIF = [tif(target_θ[i], α[j], β[j])[1] for i in 1:5, j in 1:90]

# 2領域から，敵対項目を含めないように，30項目を，テスト情報量の下限制約を満たしながら取り出す。
mod1 = Model(with_optimizer(GLPK.Optimizer))
x = @variable(mod1, 0 <= x[1:90] <= 1, Int) # Bin指定ではうまくいかない模様？なぜ？
@objective(mod1, Min, fill(1, 90)' * x)
@constraint(mod1, fill(1, 90)'x == 30) # 項目数は30個
@constraint(mod1, [fill(1,50);fill(0,40)]'x == 18) # 前半から18項目
@constraint(mod1, [fill(0,50);fill(1,40)]'x == 12) # 後半から12項目
@constraint(mod1, target_TIF[1]+1 >= IIF[1,:]'x >= target_TIF[1]) # テスト情報量の制約条件1~5
@constraint(mod1, target_TIF[2]+1 >= IIF[2,:]'x >= target_TIF[2])
@constraint(mod1, target_TIF[3]+1 >= IIF[3,:]'x >= target_TIF[3])
@constraint(mod1, target_TIF[4]+1 >= IIF[4,:]'x >= target_TIF[4])
@constraint(mod1, target_TIF[5]+1 >= IIF[5,:]'x >= target_TIF[5])
@constraint(mod1, 1 >= [fill(0,29);1;fill(0,29);1;fill(0, 29);1]'x >= 0) # 敵対項目
optimize!(mod1)
termination_status(mod1) # OPTIMAL::TerminationStatusCode = 1 ならいちおうOK
get_item = value.(x) # 複数の値が入っているので，必ずbroadchastを使う事。

get_item_id = ([1:90;][isone.(get_item)])'

using Plots
plot(tif([-4:0.1:4;], α[isone.(get_item)], β[isone.(get_item)]))
plot!(tif([-4:0.1:4;], α, β) * 30/90)


# テスト情報量の下限制約に加えて，TIFの下側の面積をなるべく小さくするように最適化する。
# 目的関数が変化するだけで，他の制約条件は不変。
mod2 = Model(with_optimizer(GLPK.Optimizer))
@variable(mod2, 0 <= x[1:90] <= 1, Int) # Bin指定ではうまくいかない模様？なぜ？
@objective(mod2, Min, α' * x) # TIFの下側の面積は識別力の和に一致する。（Item Information area index)
@constraint(mod2, fill(1, 90)'x == 30) # 項目数は30個
@constraint(mod2, [fill(1,50);fill(0,40)]'x == 18) # 前半から18項目
@constraint(mod2, [fill(0,50);fill(1,40)]'x == 12) # 後半から12項目
@constraint(mod2, target_TIF[1]+.1 >= IIF[1,:]'x >= target_TIF[1]-0) # テスト情報量の制約条件1~5
@constraint(mod2, target_TIF[2]+.1 >= IIF[2,:]'x >= target_TIF[2]-0)
@constraint(mod2, target_TIF[3]+.1 >= IIF[3,:]'x >= target_TIF[3]-0)
@constraint(mod2, target_TIF[4]+.1 >= IIF[4,:]'x >= target_TIF[4]-0)
@constraint(mod2, target_TIF[5]+.1 >= IIF[5,:]'x >= target_TIF[5]-0)
@constraint(mod2, 1 >= [fill(0,29);1;fill(0,29);1;fill(0, 29);1]'x >= 0) # 敵対項目
optimize!(mod2)
termination_status(mod2) # OPTIMAL::TerminationStatusCode = 1 ならいちおうOK
primal_status(mod2)
get_item = value.(x) # 複数の値が入っているので，必ずbroadchastを使う事。

get_item_id = ([1:90;][isone.(get_item)])'

using Plots
plot(tif([-4:0.1:4;], α[isone.(get_item)], β[isone.(get_item)]), label = "optimized test")
plot!(tif([-4:0.1:4;], α, β) * 30/90, label = "target TIF") # SUCCESS

# もうすこし問題を複雑にする。
# 全部で150個ある項目プールから，できるだけ等質なテスト版を3つ作成する。各テスト版の項目数は30項目とし，重複があってはならない。
# 項目パラメタの生成
α3 = rand(LogNormal(-0.5, 0.6), 150)
β3 = rand(Normal(0, 1.5), 150)
# 制約のためのIIF, TIFの計算
IIF3 = [tif(target_θ[i], α3[j], β3[j])[1] for i in 1:5, j in 1:150]
# IIF3 = [IIF3 IIF3 IIF3]
target_TIF3 = tif(target_θ, α3, β3) * 30/150
# target_TIF3 = [target_TIF3 target_TIF3 target_TIF3]

# create model
mod3 = Model(with_optimizer(GLPK.Optimizer))
# declare variables
@variable(mod3, 0 <= F1[1:150*3] <= 1, Int) # Test From 1 to 3
@variable(mod3, 0 <= F2[1:150*3] <= 1, Int)
@variable(mod3, 0 <= F3[1:150*3] <= 1, Int)
# objective functions
@objective(mod3, Min, repeat(α3, inner = 1, outer = 3)' * F1)
@objective(mod3, Min, repeat(α3, inner = 1, outer = 3)' * F2)
@objective(mod3, Min, repeat(α3, inner = 1, outer = 3)' * F3)
# impose constraints
# item size in each test forms
@constraint(mod3, [fill(1,150); fill(0,300)             ]'F1 == 30) # item size
@constraint(mod3, [fill(0,150); fill(1,150); fill(0,150)]'F2 == 30)
@constraint(mod3, [fill(0,300);              fill(1, 150)]'F3 == 30)
# item domain
@constraint(mod3, [fill(1,70);fill(0,80);fill(0,300)]'F1 == 18) # 前半から18項目
@constraint(mod3, [fill(0,70);fill(1,80);fill(0,300)]'F1 == 12) # 後半から12項目
@constraint(mod3, [fill(0,150);fill(1,70);fill(0,80);fill(0,150)]'F2 == 18)
@constraint(mod3, [fill(0,150);fill(0,70);fill(1,80);fill(0,150)]'F2 == 12)
@constraint(mod3, [fill(0,300);fill(1,70);fill(0,80)]'F3 == 18)
@constraint(mod3, [fill(0,300);fill(0,70);fill(1,80)]'F3 == 12)
# TIF constraints
@constraint(mod3, target_TIF3[1]+.1 >= [IIF3[1,:];fill(0,300)]'F1 >= target_TIF3[1]-.1)
@constraint(mod3, target_TIF3[2]+.1 >= [IIF3[2,:];fill(0,300)]'F1 >= target_TIF3[2]-.1)
@constraint(mod3, target_TIF3[3]+.1 >= [IIF3[3,:];fill(0,300)]'F1 >= target_TIF3[3]-.1)
@constraint(mod3, target_TIF3[4]+.1 >= [IIF3[4,:];fill(0,300)]'F1 >= target_TIF3[4]-.1)
@constraint(mod3, target_TIF3[5]+.1 >= [IIF3[5,:];fill(0,300)]'F1 >= target_TIF3[5]-.1)

@constraint(mod3, target_TIF3[1]+.1 >= [fill(0,150);IIF3[1,:];fill(0,150)]'F2 >= target_TIF3[1]-.1)
@constraint(mod3, target_TIF3[2]+.1 >= [fill(0,150);IIF3[2,:];fill(0,150)]'F2 >= target_TIF3[2]-.1)
@constraint(mod3, target_TIF3[3]+.1 >= [fill(0,150);IIF3[3,:];fill(0,150)]'F2 >= target_TIF3[3]-.1)
@constraint(mod3, target_TIF3[4]+.1 >= [fill(0,150);IIF3[4,:];fill(0,150)]'F2 >= target_TIF3[4]-.1)
@constraint(mod3, target_TIF3[5]+.1 >= [fill(0,150);IIF3[5,:];fill(0,150)]'F2 >= target_TIF3[5]-.1)

@constraint(mod3, target_TIF3[1]+.1 >= [fill(0,300);IIF3[1,:]]'F3 >= target_TIF3[1]-.1)
@constraint(mod3, target_TIF3[2]+.1 >= [fill(0,300);IIF3[2,:]]'F3 >= target_TIF3[2]-.1)
@constraint(mod3, target_TIF3[4]+.1 >= [fill(0,300);IIF3[4,:]]'F3 >= target_TIF3[4]-.1)
@constraint(mod3, target_TIF3[3]+.1 >= [fill(0,300);IIF3[3,:]]'F3 >= target_TIF3[3]-.1)
@constraint(mod3, target_TIF3[5]+.1 >= [fill(0,300);IIF3[5,:]]'F3 >= target_TIF3[5]-.1)

# between test forms
for j in 1:150
    @constraint(mod3, 1 >= [F1[j] + F2[j+150] + F3[j+300]][1] >= 0)
end

mod3
# JuMP.backend(mod3) # 偉いことになるので実行NG

@time optimize!(mod3)
termination_status(mod3) # OPTIMAL::TerminationStatusCode = 1 ならいちおうOK
get_F1 = value.(F1)
get_F2 = value.(F2)
get_F3 = value.(F3)

plot(tif([-4:0.1:4;], α3[isone.(get_F1)], β3[isone.(get_F1)]), label = "optimized test F1")
plot(tif([-4:0.1:4;], α3[isone.(get_F2)], β3[isone.(get_F2)]), label = "optimized test F2")
plot(tif([-4:0.1:4;], α3[isone.(get_F3)], β3[isone.(get_F3)]), label = "optimized test F3")
plot!(tif([-4:0.1:4;], α3, β3) * 30/90, label = "target TIF") # SUCCESS


# JuMP_temp.jlの結果を反映させて，再度項目数を増やしてみて実行
Random.seed!(1234)
α4 = rand(LogNormal(-0.5, 0.6), 150)
β4 = rand(Normal(0, 1.5), 150)
target_θ4 = [-2:1:2;]
target_TIF4 = tif(target_θ4, α4, β4) * 30/150
IIF4 = [tif(target_θ4[i], α4[j], β4[j])[1] for i in 1:length(target_θ4), j in 1:150]
# create model
mod4 = Model(with_optimizer(GLPK.Optimizer))
# declare variables
@variable(mod4, 0 <= F1[1:150] <= 1, Int) # Test From 1 to 3
@variable(mod4, 0 <= F2[1:150] <= 1, Int)
@variable(mod4, 0 <= F3[1:150] <= 1, Int)
# objective functions
@objective(mod4, Min, α4' * F1)
@objective(mod4, Min, α4' * F2)
@objective(mod4, Min, α4' * F3)
# impose constraints
# item size in each test forms
@constraint(mod4, fill(1,150)'F1 == 30) # item size
@constraint(mod4, fill(1,150)'F2 == 30)
@constraint(mod4, fill(1,150)'F3 == 30)
# item domain
@constraint(mod4, [fill(1,100);fill(0,50)]'F1 == 20) # 前半から18項目
@constraint(mod4, [fill(0,100);fill(1,50)]'F1 == 10) # 後半から12項目
@constraint(mod4, [fill(1,100);fill(0,50)]'F2 == 20)
@constraint(mod4, [fill(0,100);fill(1,50)]'F2 == 10)
@constraint(mod4, [fill(1,100);fill(0,50)]'F3 == 20)
@constraint(mod4, [fill(0,100);fill(1,50)]'F3 == 10)
# TIF constraints
for i in 1:5 # the number of evaluated points
    @constraint(mod4, target_TIF4[i]+.1 >= IIF4[i,:]'F1 >= target_TIF4[i]-.1)
    @constraint(mod4, target_TIF4[i]+.1 >= IIF4[i,:]'F2 >= target_TIF4[i]-.1)
    @constraint(mod4, target_TIF4[i]+.1 >= IIF4[i,:]'F3 >= target_TIF4[i]-.1)
end
# between test forms
for j in 1:150 # the number of items in the item pool
    @constraint(mod4, 1 >= [F1[j] + F2[j] + F3[j]][1] >= 0)
end
mod4
# JuMP.backend(mod4) # 偉いことになるので実行NG

@time optimize!(mod4)
termination_status(mod4) # OPTIMAL::TerminationStatusCode = 1 ならいちおうOK
get_F1 = value.(F1)
get_F2 = value.(F2)
get_F3 = value.(F3)

([1:60;][isone.(get_F1)])'
([1:60;][isone.(get_F2)])'
([1:60;][isone.(get_F3)])'

plot([-4:0.1:4;], tif([-4:0.1:4;], α3[isone.(get_F1)], β3[isone.(get_F1)]), label = "optimized test F1")
plot!([-4:0.1:4;], tif([-4:0.1:4;], α3[isone.(get_F2)], β3[isone.(get_F2)]), label = "optimized test F2")
plot!([-4:0.1:4;], tif([-4:0.1:4;], α3[isone.(get_F3)], β3[isone.(get_F3)]), label = "optimized test F3")
plot!([-4:0.1:4;], tif([-4:0.1:4;], α3, β3) * 10/60, label = "target TIF") # SUCCESS
