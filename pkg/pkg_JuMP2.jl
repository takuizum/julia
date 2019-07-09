using JuMP, GLPK, Random, Distributions, StatsFuns

# generate sample item paraemters

α = rand(LogNormal(-0.5, 0.7), 90)
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
