# Chapter 3: Data Engineering

pwd()

f = open("my_data.txt", "w") # 2つ目の引数がkeyword
write(f, "first\nsecond\nthird")
f = open("my_data.txt", "r")
readline(f) # 1行ごとに読み込む事ができる。
read(f)
eof(f)
close(f)

data = open("my_data.txt", "r") do f
    read(f) # readの場合はbinaryで読み込もうとするので，plain textにはなってくれない。
end

String(data)# これで元の形に読み込める。


# Chapter 4: Numerical Computing with Julia

# Juliaの中ではcolumn優先でデータを保持するので，行ごとよりも列ごとに演算したほうが高速になる。
using BenchmarkTools

function sum_by_col(x)
    s = zero(eltype(x))
    for j in 1:size(x, 2)
        for i in 1:size(x, 1)
            s += x[i, j]
        end
    end
    s
end

function sum_by_row(x)
    s = zero(eltype(x))
    for i in 1:size(x, 1)
        for j in 1:size(x, 2)
            s += x[i, j]
        end
    end
    s
end

x = rand(10^4, 10^4)
@btime sum_by_row(x) # 895.902 ms (1 allocation: 16 bytes)
@btime sum_by_col(x) # 119.006 ms (1 allocation: 16 bytes)
@btime sum(x) # もちろんこれが一番高速

# loopの効率のよい実行方法
x = randn(10^6)

# type 1
# 一行で書くことがdきるが，あまりパフォーマンスは良くない。
sum(v for v in x if v > 0)
# type 2
# つぎはloopにして，関数化する。
function possum1(x)
    s = zero(eltype(x)) # オブジェクトの型を自動的に判別してくれる。
    for v in x
        if(v > 0)
            s += v
        end
    end
    s
end
possum1(x)
# type 3
# loopの中のif(conditional statement)は効率が悪いので，ifelseで置き換える。
function possum2a(x)
    s = zero(eltype(x)) # オブジェクトの型を自動的に判別してくれる。
    for v in x
        s += ifelse(v > 0, v, zero(s))
    end
    s
end
possum2(x)
# type 4
# add @simd macro
function possum2b(x)
    s = zero(eltype(x)) # オブジェクトの型を自動的に判別してくれる。
    @simd for v in x
        s += ifelse(v > 0, v, zero(s))
    end
    s
end
# poor implemention
# 0の型判定が不安定なので，速度が遅い。
function possum2c(x)
    s = zero(eltype(x)) # オブジェクトの型を自動的に判別してくれる。
    @simd for v in x
        s += ifelse(v > 0, v, 0)
    end
    s
end

@btime possum2a(x)
@btime possum2b(x) # 爆速
@btime possum2c(x)

# つまりJuliaのloopの中の判定は ifelse と @simd を使えってこと。


# Genarating full factorial designs
# 要するにexpand.grid
