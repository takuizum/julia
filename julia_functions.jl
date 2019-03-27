# functions

# 基本形
function f(x, y)
    x^2+y^2
end

f(3,4)

# 勿論unicodeも使える
function µ(x)
    y = sum(x)/length(x)
    return x # returnで指定した文字列を強制的に吐き出す
    x = sum(x) # それ移行で値を変更しても無駄
end

µ([1,2,3,4,5,6])
# more terse syntax
g(x) = sum(x)/length(x)
g([1,2,3,4,5,6])
# specify return type
h(x)::Int8 = sum(x)/length(x) # function~の書き出しでも使用できる。
h([1,2,3])

# anonymus function + map()
map(x -> sqrt(x), [1,2,3,4,5,6,7,8,9])
map(x -> sqrt(x), [1,2,3,4,5,6,7,8,0])

# tuples: a built-in data structure that can hold any value, but cannot be modified.
# It is constructer with commas and parentheses, and can be accessed by indexing.
x = ("1", 1, "abc", [1,2,3,4])
x[4]
x[[1,3]]
(1,) # this tuples length is 1
() # length-0 tuples
# named tuples
y = (a = 1, b = "1", c = f(x) = x^2)
y.c(4) #tuplesから呼び出し。なんと関数もはいっちゃう。
1,2 # tuples without parentheses
x[1] = 1 # immutable

# Varags Function: variable length function
bar(a,b,x...) = (a,b,x)
bar(1,2,3,4,5)
bar(1,2,[1,2,3,4,5]...)
bar(1,2,[1,2,3,4,5]) # not same
x = [1,2]
bar(1,2,x...)
# Optional Arguments
#using Dates
#function Date(y::Int64, m::Int64=1, d::Int64=1)
    # err = Dates.validargs(Date, y, m, d)
    #Dates パッケージの提供する関数のようだが，使い方は不明
    # err === nothing || throw(err)
    #return Date(UTD(totaldays(y, m, d)))
#end
#Date(2000, 12, 12)

# Do-Block Syntax
map(x->begin
           if x < 0 && iseven(x) # 負，かつ偶数ならば
               return 0
           elseif x == 0
               return 1
           else
               return x
           end
       end,
    [-2, -1, 0, 1, 2])
# 同じことがdoをもちいても書ける
map([-2, -1, 0, 1, 2]) do x
    if x < 0 && iseven(x)
        return 0
    elseif x == 0
        return 1
    else
        return x
    end
end

# Dot Syntax
# f.() is elementwise
A = [1,2,3,4,5]
sin(A)
sin.(A)
map(sin, A) # これと同じ意味
# effective syntax
Y = [1.0, 2.0, 3.0, 4.0]; # ちなみに;を最後につければ，結果がよこに表示されないようだ。
# pre-allocate output array
X = similar(Y); # similar(): create an uninitialized mutable array
X = sin.(cos.(Y))
@. X = sin(cos(Y)) # いちいち.を書かなくてもOK
broadcast(*, 2.0, (2.0, 3.0))　# これでもOK
