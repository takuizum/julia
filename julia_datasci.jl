using Pkg
Pkg.update()

# data type
typeof(1)
typeof(1.0)

x = 1
x += 3 # updating operators

# dot operators
[1,2,3] # column vector
[1,2,3]
[1, 2, 3] .^3 # . operators = 要素ごとの演算
#クロネッカー積 = kron(,) or ⊗

# Numeric comparison
#!= is same mean to ≠(alt + ^)

1 ≠ 1.0
1 == 1.0
# !?
NaN == NaN
missing == missing
missing == Inf
isequal(1, 1)
isequal(NaN, NaN) # !?
# chaining comparison
x = 1
y = 2
z = 4
x < y < 3 < z
1 ≥ 1 # alt + >
# special symbol
# Greek symbols # alt + ¥
#⊗ # cmd + v
#√ # alt + v

round(1.3)
round(Int128, 1.2)
ceil(5.6)
trunc(5.6)

# divisdion func
gcd(6, 12, 15) # 最大公約数 greatest positive common divisor
lcm(6, 12, 15) # 最小公倍数 least positive common multiple

abs(-5)
abs(-5)

# complex number
1 + 2im
# rational values
6//9
2//4 + 1//6
2//3 == 9//27
3//5 + 1
3//5 + 2 # 左側にしか加算されない。


# julia pipe operator
"abc" |> x->repeat(x,5) |> x->string(x,"5times") # 複数の引数があるときは明示的に指定
[1:5;] |> sum
