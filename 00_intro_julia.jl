# introduction to Julia lang

struct Complex1
    real::Float64
    imag::Float64
end
typeof(Complex1)

struct Complex2{T}
    real::T
    imag::T
end
Complex2

struct Person # Personという構造体（データ型）を定義する。
    name::String # nameという変数はString型
end
function sayhello(person::Person)　# personという変数はPerson型
    println("Hi, I'm ", person.name) # personという変数はPerson型であり，Person型にはnameというフィールドが定義されているので，それを呼び出す。
end

sayhello(Person("takumi")) # この関数はsingle dispatchの例


# juliaの制御構文
# for loop
x = 10
if x < 11
    print(x, "は",11, "よりちいさい")
else
    print(x, "は",11　,"よりおおきい")
end

# これを関数にする
function どっちがおおきい(T::Number)
    if T < 11
        print(T, "は",11, "よりちいさい")
    else
        print(T, "は",11　,"よりおおきい")
    end
end # of function
どっちがおおきい(12)

# while loop
t = 1
while t < 100000
    global t += 1
    print(t, "time iteration\r")
    randam = randn(10)
end

# juliaの配列
xs = [1,2,3]
xs[1]
xs[1:2]
xs[2:end]
xs[3:1] # これはダメ
xs[1] = 10
xs[1:2] = [100, 200]
xs[1:3] .= 0 # broadcast 演算子でスカラ値をベクトル全体に上書き。
# multi dim array
A = [1.0 3.0;2.0 4.0] # 列ベクトルの時と違って，`,`は不要。行の境目は`;`
col = [1,2] # `,`で区切ると列
row = [1 2] # スペースで区切ると行
A .* A
row * col
col*row
A * col
A' # transpose
# over 3 dims
# Array{type}(dims)
Array(Float64, 2)
B = Array{Float64}(undef, 2, 2) # undefは要素が初期化されていない空の配列
zeros(3,2,3) # dimと大きさを指定して0配列が作れる。
ones(Int64, 2, 3)

# reshape メモリ配置が同じで，サイズの異なる配列を生成，基本列が優先，戻り値はAbstractArray
reshape(1:10, 2, 5)
reshape(1:10, 2, 6) # 最終的な要素数が，変換前の要素数と一致していないとだめ
reshape(1:6, 1, :)
reshape([1 2 ; 3 4], 1, :) # 次元のうちひとつは`:`で省略可能

# broadcasting
