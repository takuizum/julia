# Jilia rounding

d = [7.8949999,7.8950001,7.8950000,7.8850000]

@show round.(d, digits = 2)

sign(-1)

# 正しい？roundの定義
# function round2(x, digits=0) sign(x) * floor( abs(x) * 10^digits + 0.5 ) / (10^digits) end
round2(x; digits=0) = sign(x) * floor( abs(x) * 10^digits + 0.5 ) / (10^digits)
# keyword arguments について
# https://docs.julialang.org/en/v1/manual/functions/index.html#Keyword-Arguments-1
@show round2.(d, digits = 2)
