# Think Julia

# Furuitful Functions

# recursion
function countdown(n)
    if n ≤ 0
        println("Blastoff!")
    else
        print(n, " ")
        countdown(n-1)
    end
end

countdown(10)

# Exercise 6-5
function ack(m, n)
    if m == 0
        return n + 1
    elseif m > 0 && n == 0
        return ack(m-1, 1)
    elseif m > 0 && n > 0
        tmp = ack(m, n-1)
        return ack(m-1, tmp)
    end
end

@time ack(3, 4)
@time ack(3, 6)
for i in 1:15 # n=15程度でオーバーフロー
    @show i
    @time ack(3, i)
end

for j in 1:15 # mはかなりちいさな値でもオーバーフローする
    @show j
    @time ack(j, 3)
end

# Exercise 6-7
"""
ispower(a, b)

Calculate a power, b, of a.
"""
function ispower(a::Int64, b::Int64)
    dvd = a/b
    if (dvd % b) == 0
        print(b, " is a power of ", a, " and a power is ", convert(Int64, dvd))
        return true
    else
        print(b, " is NOT a power of ", a)
        return false
    end
end

ispower(9, 2)


# Exercise 6-8
function gcd(a, b)
    ### This function remains to be coded
end

# 7. Iteration

function mysqrt(x, a, ε = 1e-10)
    # x is initial value.
    # a is a value to figure out its square root.
    while true
        # println(x)
        y = (x + a/x) / 2
        if abs(y-x) < ε
            return y
            break
        end
        x = y
    end
end

mysqrt(10, 2) |> typeof

# Exercise 7-2
using DataFrames
function testsqareroot(upto) 
    # define sqrt function
    function mysqrt(x, a, ε = 1e-10)
        # x is initial value.
        # a is a value to figure out its square root.
        while true
            y = (x + a/x) / 2
            if abs(y-x) < ε
                return y
                break
            end
            x = y
        end
    end
    # initialize
    a = [1.0:1.0:upto;]
    mysqrt_vec = zeros(length(a))
    sqrt_vec  = zeros(length(a))
    diff_vec = zeros(length(a))
    init = upto
    @. mysqrt_vec = mysqrt(init, a)
    @. sqrt_vec   = sqrt(a)
    @. diff_vec   = mysqrt_vec - sqrt_vec
    res = DataFrame(a = a, mysqrt = mysqrt_vec, sqrt = sqrt_vec, diff = diff_vec)
    @show res
    return res
end

test = testsqareroot(20)

# Exercise 7-3
Meta.parse("sqrt(π)")

function evalloop(eval_expr)
    flag = true
    while(flag)
        Meta.parse(eval_expr)
        print("Have you be satisfied with this iteration? If so, enter 'done'.")
        txt = readline()
        if(txt == "done")
            flag = false
        end
    end
end

evalloop("1+3")

# 8. Strings
fruit = "🍌"
fruit |> typeof
fruit[1]
fruit[2] # Error
sizeof(fruit)

fruit = "banana"
fruit[2]
fruit[end]
sizeof(fruit)

fruits = "🍌🍎🍐"
fruits |> sizeof
fruits[1]
fruits[5]
fruits[4]

# Traversal
# スタート地点から順番になにかの文字を取得して，何かを実行し，最後までそれを続けること。そのようなprocessingがtraversalである。
# 数値的なインデックスを使うのか，それともベクトルの要素を取るのかで，書き方がちょっと異なる。
index = firstindex(fruits)
while index <= sizeof(fruits)
    letter = fruits[index]
    println(letter)
    global index = nextind(fruits, index) # ここでグローバルを上書きしておく。
end
# さらに簡単なVer
for letter in fruits
    println(letter)
end

# String Slice
str = "Julius Caesar";
str[1:6]
str[:]

# String Interpolation
# String内でJuliaオブジェクトを参照する。
"1 + 2 = $(1 + 2)"

# String Library
uppercase("Hello, World")
lowercase("ABCDSkofkofe")

findfirst("a", "banana")
findfirst("na", "banana")

findnext("na", "banana", 4)

# The ∈ Operator
# Returns `true` if first arg appears in the second.
'a' ∈ "banana"

function inboth(word1, word2)
    for letter in word1
        if letter ∈ word2
            print(letter, " ")
        end
    end
end
inboth("apples", "oranges")

# 9. Case Study
