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

using DataFrames
function testsqareroot(upto) # This function remains to update...
    # define sqrt function
    # function mysqrt(x, a, ε = 1e-10)
    #     # x is initial value.
    #     # a is a value to figure out its square root.
    #     while true
    #         y = (x + a/x) / 2
    #         if abs(y-x) < ε
    #             return y
    #             break
    #         end
    #         x = y
    #     end
    # end
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

str = "Julius Caesar";
str[1:6]
str[:]

"1 + 2 = $(1 + 2)"  
