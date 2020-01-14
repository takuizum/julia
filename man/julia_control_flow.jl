# Control Frow

# compound expressions
# use "begin" syntax or ";" symbol
z = begin
    x = "use begin semantics"
    y = " and use ; symbol"
    println(x, y)
end

# The bigin block must end 'end'
begin
    x = 1
    y = 2
    x + y
end
(x = 1; y = 2; x + y)

# conditional evaluation(関数にも入れることができる)
x = 1
y = 2
if x < y
    println("condition 1")
elseif x > y
    println("condition 2")
else
    println("condition 3")
end
# ただし，基本的にif blockはleaklyなので注意（Rとかと一緒）
function test(x, y)
    if x < y
        relation = "less than"
    elseif x == y
        relation = "equal to"
    else
        relation = "greater than"
    end
    println("x is ", relation, " y.")
end
test(1, 2);
test(2, 1);
test(1, 1);
# condition type
if 1 # Rはこれでもいけちゃうけど
    println("true") # Rはこれでもいけちゃうけど
end # Rはこれでもいけちゃうけど
# ternary operator '?:'
x = 2
x == 1 ? println("true") : println("false")
# ただしsingle expression valueのときにしか使えない。
println(x == 1 ? "true" : "false")
# 連結すれば，いくらでもいけちゃう
test(x, y) =
    println(x < y ? "x is less than y" : x > y ? "x is greater than y" : "x is equal to y")
test(1, 2)

# short-circuit evaluation
# && = かつ, || = または

# repeated evaluation
# while
x = 1
while x <= 5
    #print(x) # print だと改行されないみたい
    println(x)
    global x += 1
end
x = 1
while x <= 10000
    print(x, "\r") # print だと改行されないみたい
    global x += 1
end
# for
for i = 1:100
    print(i, "\r")
end
i # iはglobalには存在しない。for blockの中だけで定義されているから？
for s ∈ ["foo", "bar", "baz"] # ∈の出し方はよく分からない = JUNOならば\inでいける
    println(s)
end
# break と continueは一般的な使い方でいける模様

# The throw function # ちょっとまだ使い方がよく分かっていない
# See also "https://docs.julialang.org/en/v1/manual/control-flow/#Built-in-Exceptions-1"
# 負の数が与えられた場合にエラーメッセージを吐く
f(x) = x >= 0 ? exp(-x) : throw(DomainError(x, "argument must be nonnegative"))
f(-2)

# Errors
fussy_sqrt(x) = x >= 0 ? sqrt(x) : error("negative x not allowed")
fussy_sqrt(-2) # "うるさい"平方根w

# tyr & catch statement
f(x) =
    try
        sqrt(x)
    catch
        sqrt(complex(x, 0))
    end
f(-1)
# finally
f(x) =
    try
        sqrt(x)
    catch
        sqrt(complex(x, 0))
    finally
        println("complete!")
    end
f(-1)
