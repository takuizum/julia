α3 = rand(LogNormal(-0.5, 0.6), 60)
β3 = rand(Normal(0, 1.5), 60)
# 制約のためのIIF, TIFの計算
IIF3 = [tif(target_θ[i], α3[j], β3[j])[1] for i in 1:5, j in 1:60]
# IIF3 = [IIF3 IIF3 IIF3]
target_TIF3 = tif(target_θ, α3, β3) * 10/60
# target_TIF3 = [target_TIF3 target_TIF3 target_TIF3]

# create model
mod3 = Model(with_optimizer(GLPK.Optimizer))
# declare variables
@variable(mod3, 0 <= F1[1:60*3] <= 1, Int) # Test From 1 to 3
@variable(mod3, 0 <= F2[1:60*3] <= 1, Int)
@variable(mod3, 0 <= F3[1:60*3] <= 1, Int)
# objective functions
@objective(mod3, Min, repeat(α3, inner = 1, outer = 3)' * F1)
@objective(mod3, Min, repeat(α3, inner = 1, outer = 3)' * F2)
@objective(mod3, Min, repeat(α3, inner = 1, outer = 3)' * F3)
# impose constraints
# item size in each test forms
@constraint(mod3, [fill(1,60); fill(0,120)             ]'F1 == 10) # item size
@constraint(mod3, [fill(0,60); fill(1,60); fill(0,60)]'F2 == 10)
@constraint(mod3, [fill(0,120);              fill(1, 60)]'F3 == 10)
# item domain
@constraint(mod3, [fill(1,35);fill(0,25);fill(0,120)]'F1 == 7) # 前半から18項目
@constraint(mod3, [fill(0,35);fill(1,25);fill(0,120)]'F1 == 3) # 後半から12項目
@constraint(mod3, [fill(0,60);fill(1,35);fill(0,25);fill(0,60)]'F2 == 7)
@constraint(mod3, [fill(0,60);fill(0,35);fill(1,25);fill(0,60)]'F2 == 3)
@constraint(mod3, [fill(0,120);fill(1,35);fill(0,25)]'F3 == 7)
@constraint(mod3, [fill(0,120);fill(0,35);fill(1,25)]'F3 == 3)
# TIF constraints
@constraint(mod3, target_TIF3[1]+.1 >= [IIF3[1,:];fill(0,120)]'F1 >= target_TIF3[1]-.1)
@constraint(mod3, target_TIF3[2]+.1 >= [IIF3[2,:];fill(0,120)]'F1 >= target_TIF3[2]-.1)
@constraint(mod3, target_TIF3[3]+.1 >= [IIF3[3,:];fill(0,120)]'F1 >= target_TIF3[3]-.1)
@constraint(mod3, target_TIF3[4]+.1 >= [IIF3[4,:];fill(0,120)]'F1 >= target_TIF3[4]-.1)
@constraint(mod3, target_TIF3[5]+.1 >= [IIF3[5,:];fill(0,120)]'F1 >= target_TIF3[5]-.1)

@constraint(mod3, target_TIF3[1]+.1 >= [fill(0,60);IIF3[1,:];fill(0,60)]'F2 >= target_TIF3[1]-.1)
@constraint(mod3, target_TIF3[2]+.1 >= [fill(0,60);IIF3[2,:];fill(0,60)]'F2 >= target_TIF3[2]-.1)
@constraint(mod3, target_TIF3[3]+.1 >= [fill(0,60);IIF3[3,:];fill(0,60)]'F2 >= target_TIF3[3]-.1)
@constraint(mod3, target_TIF3[4]+.1 >= [fill(0,60);IIF3[4,:];fill(0,60)]'F2 >= target_TIF3[4]-.1)
@constraint(mod3, target_TIF3[5]+.1 >= [fill(0,60);IIF3[5,:];fill(0,60)]'F2 >= target_TIF3[5]-.1)

@constraint(mod3, target_TIF3[1]+.1 >= [fill(0,120);IIF3[1,:]]'F3 >= target_TIF3[1]-.1)
@constraint(mod3, target_TIF3[2]+.1 >= [fill(0,120);IIF3[2,:]]'F3 >= target_TIF3[2]-.1)
@constraint(mod3, target_TIF3[4]+.1 >= [fill(0,120);IIF3[4,:]]'F3 >= target_TIF3[4]-.1)
@constraint(mod3, target_TIF3[3]+.1 >= [fill(0,120);IIF3[3,:]]'F3 >= target_TIF3[3]-.1)
@constraint(mod3, target_TIF3[5]+.1 >= [fill(0,120);IIF3[5,:]]'F3 >= target_TIF3[5]-.1)

# between test forms
for j in 1:60
    @constraint(mod3, 1 >= [F1[j] + F2[j+60] + F3[j+120]][1] >= 0)
end
mod3
# JuMP.backend(mod3) # 偉いことになるので実行NG

@time optimize!(mod3)
termination_status(mod3) # OPTIMAL::TerminationStatusCode = 1 ならいちおうOK
get_F1 = value.(F1)
get_F2 = value.(F2)
get_F3 = value.(F3)

([1:60; 1:60; 1:60][isone.(get_F1)])'
([1:60; 1:60; 1:60][isone.(get_F2)])'
([1:60; 1:60; 1:60][isone.(get_F3)])'

plot(tif([-4:0.1:4;], [α3 α3 α3][isone.(get_F1)], [β3 β3 β3][isone.(get_F1)]), label = "optimized test F1")
plot!(tif([-4:0.1:4;], [α3 α3 α3][isone.(get_F2)], [β3 β3 β3][isone.(get_F2)]), label = "optimized test F2")
plot!(tif([-4:0.1:4;], [α3 α3 α3][isone.(get_F3)], [β3 β3 β3][isone.(get_F3)]), label = "optimized test F3")
plot!(tif([-4:0.1:4;], α3, β3) * 10/60, label = "target TIF") # SUCCESS
